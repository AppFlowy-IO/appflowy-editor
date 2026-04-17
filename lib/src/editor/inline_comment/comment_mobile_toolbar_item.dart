import 'dart:async';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/inline_comment/comment_utils.dart';
import 'package:flutter/material.dart';

/// Returns a [MobileToolbarItem] that adds an inline comment to the current
/// text selection.
///
/// Pass the [InlineCommentController] that manages comments for the editor.
///
/// The item icon is hidden (returns `null`) when:
/// - There is no active selection.
/// - The selection is collapsed (no text selected).
/// - None of the selected nodes carries a delta.
///
/// When the user taps the icon the same add-comment flow as the desktop item
/// is executed: existing comment-ids are collected, [onCommentAdded] is called,
/// and the result is written back via [EditorState.formatDelta].
MobileToolbarItem buildCommentMobileToolbarItem(
  InlineCommentController controller,
) {
  return MobileToolbarItem.action(
    itemIconBuilder: (context, editorState, __) {
      final selection = editorState.selection;
      if (selection == null || selection.isCollapsed) return null;
      if (!selection.isSingle) return null;

      final node = editorState.getNodeAtPath(selection.start.path);
      if (node?.delta == null) return null;

      return Icon(
        Icons.comment_outlined,
        color: MobileToolbarTheme.of(context).iconColor,
        size: 22,
      );
    },
    actionHandler: (context, editorState) {
      unawaited(_addComment(controller, editorState));
    },
  );
}

Future<void> _addComment(
  InlineCommentController controller,
  EditorState editorState,
) async {
  final selection = editorState.selection?.normalized;
  if (selection == null || selection.isCollapsed) return;

  // Only single-node selections are supported.
  if (!selection.isSingle) return;

  final node = editorState.getNodeAtPath(selection.start.path);
  if (node == null || node.id.isEmpty) return;

  final existingIds = collectExistingCommentIds(editorState, selection);

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
