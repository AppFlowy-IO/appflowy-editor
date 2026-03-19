import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/inline_comment/inline_comment_service_widget.dart';
import 'package:flutter/material.dart';

/// Mobile toolbar item that adds an inline comment to the current text
/// selection.
///
/// The item icon is hidden (returns `null`) when:
/// - There is no active selection.
/// - The selection is collapsed (no text selected).
/// - None of the selected nodes carries a delta.
///
/// When the user taps the icon the same add-comment flow as the desktop item
/// is executed: existing comment-ids are collected, [onCommentAdded] is called,
/// and the result is written back via [EditorState.formatDelta].
final commentMobileToolbarItem = MobileToolbarItem.action(
  itemIconBuilder: (context, editorState, __) {
    final selection = editorState.selection;
    if (selection == null || selection.isCollapsed) return null;

    final nodes = editorState.getNodesInSelection(selection);
    if (!nodes.any((n) => n.delta != null)) return null;

    return Icon(
      Icons.comment_outlined,
      color: MobileToolbarTheme.of(context).iconColor,
      size: 22,
    );
  },
  actionHandler: (context, editorState) {
    _addComment(context, editorState);
  },
);

Future<void> _addComment(
  BuildContext context,
  EditorState editorState,
) async {
  final selection = editorState.selection?.normalized;
  if (selection == null || selection.isCollapsed) return;

  // Only single-node selections are supported.
  if (!selection.isSingle) return;

  final node = editorState.getNodeAtPath(selection.start.path);
  if (node == null || node.id.isEmpty) return;

  final controller = InlineCommentScope.of(context);
  if (controller == null) return;

  final existingIds = _collectExistingCommentIds(editorState, selection);

  final commentId = await controller.onCommentAdded(
    node.id,
    selection.startIndex,
    selection.endIndex,
    null,
  );

  if (commentId == null) return;

  await editorState.formatDelta(
    selection,
    {
      AppFlowyRichTextKeys.commentIds: [...existingIds, commentId],
    },
  );
}

List<String> _collectExistingCommentIds(
  EditorState editorState,
  Selection selection,
) {
  final existing = <String>{};
  final nodes = editorState.getNodesInSelection(selection);
  for (final node in nodes) {
    final delta = node.delta;
    if (delta == null) continue;
    for (final op in delta) {
      if (op is TextInsert) {
        final raw = op.attributes?[AppFlowyRichTextKeys.commentIds];
        if (raw is List) {
          existing.addAll(raw.map((e) => e.toString()));
        } else if (raw is String) {
          existing.add(raw);
        }
      }
    }
  }
  return existing.toList();
}
