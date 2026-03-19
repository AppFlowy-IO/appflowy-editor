import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/inline_comment/comment_utils.dart';
import 'package:appflowy_editor/src/editor/inline_comment/inline_comment_controller.dart';
import 'package:appflowy_editor/src/editor/inline_comment/inline_comment_service_widget.dart';
import 'package:flutter/material.dart';

const _kCommentItemId = 'editor.comment';

/// Desktop floating-toolbar button that adds an inline comment to the current
/// text selection.
///
/// The button is active whenever there is a non-collapsed text selection that
/// spans at least one node with a delta (text) type. Clicking it:
///
/// 1. Normalises the current [Selection].
/// 2. Collects any comment-ids already present in the selected range so that
///    they are not overwritten.
/// 3. Calls [InlineCommentController.onCommentAdded] to obtain a new comment id
///    from the host app.
/// 4. Writes `{AppFlowyRichTextKeys.commentIds: [...existingIds, newId]}` into
///    the delta via [EditorState.formatDelta].
final commentToolbarItem = ToolbarItem(
  id: _kCommentItemId,
  group: 4,
  isActive: _isActive,
  builder: (context, editorState, highlightColor, iconColor, tooltipBuilder) {
    final child = _CommentToolbarButton(
      editorState: editorState,
      iconColor: iconColor,
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
  });

  final EditorState editorState;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.comment_outlined,
        size: 16,
        color: iconColor,
      ),
      onPressed: () => _onPressed(context),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 28, height: 28),
    );
  }

  Future<void> _onPressed(BuildContext context) async {
    final selection = editorState.selection?.normalized;
    if (selection == null || selection.isCollapsed) return;

    // Only single-node selections are supported (comment spans one node).
    if (!selection.isSingle) return;

    final node = editorState.getNodeAtPath(selection.start.path);
    if (node == null || node.id.isEmpty) return;

    final controller = InlineCommentScope.of(context);
    if (controller == null) return;

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

