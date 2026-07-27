import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/inline_comment/comment_utils.dart';
import 'package:flutter/material.dart';

const _kCommentItemId = 'editor.comment';

/// Returns a [ToolbarItem] that adds an inline comment on the selected text.
///
/// Pass the [InlineCommentController] that manages comments for the editor.
///
/// Usage:
/// ```dart
/// AppFlowyEditor(
///   floatingToolbarItems: [
///     ...standardFloatingToolbarItems,
///     buildCommentToolbarItem(myController),
///   ],
/// )
/// ```
ToolbarItem buildCommentToolbarItem(InlineCommentController controller) {
  return ToolbarItem(
    id: _kCommentItemId,
    group: 4,
    isActive: _isActive,
    builder: (context, editorState, highlightColor, iconColor, tooltipBuilder) {
      final child = _CommentToolbarButton(
        editorState: editorState,
        iconColor: iconColor,
        controller: controller,
      );

      if (tooltipBuilder != null) {
        return tooltipBuilder(
          context,
          _kCommentItemId,
          'Comment',
          child,
        );
      }

      return child;
    },
  );
}

bool _isActive(EditorState editorState) {
  final selection = editorState.selection;
  if (selection == null || selection.isCollapsed) return false;
  if (!selection.isSingle) return false;
  final node = editorState.getNodeAtPath(selection.start.path);
  return node?.delta != null;
}

// ---------------------------------------------------------------------------
// Internal button widget — keeps async logic out of the builder closure.
// ---------------------------------------------------------------------------

class _CommentToolbarButton extends StatelessWidget {
  const _CommentToolbarButton({
    required this.editorState,
    required this.iconColor,
    required this.controller,
  });

  final EditorState editorState;
  final Color? iconColor;
  final InlineCommentController controller;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.comment_outlined,
        size: 16,
        color: iconColor,
      ),
      onPressed: () => _onPressed(),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 28, height: 28),
    );
  }

  Future<void> _onPressed() async {
    final selection = editorState.selection?.normalized;
    if (selection == null || selection.isCollapsed) return;

    // Only single-node selections are supported (comment spans one node).
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
}
