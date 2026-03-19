import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'inline_comment.dart';
import 'inline_comment_controller.dart';
import 'inline_comment_service.dart';
import 'comment_card_widget.dart';

/// Desktop sidebar that displays all [InlineComment]s aligned to their
/// text anchors in the editor.
///
/// Uses [InlineCommentService.scanAnchors] to determine each comment's
/// vertical position by resolving its anchor to a screen Y-coordinate,
/// then renders comment cards in a [Stack] with [Positioned] children.
class CommentSidebarWidget extends StatefulWidget {
  const CommentSidebarWidget({
    super.key,
    required this.editorState,
    required this.controller,
    required this.child,
    this.sidebarWidth = 240.0,
  });

  final EditorState editorState;
  final InlineCommentController controller;

  /// The editor widget (takes all remaining horizontal space).
  final Widget child;

  /// Width of the sidebar in logical pixels.
  final double sidebarWidth;

  @override
  State<CommentSidebarWidget> createState() => _CommentSidebarWidgetState();
}

class _CommentSidebarWidgetState extends State<CommentSidebarWidget> {
  final Map<String, double> _commentTopPositions = {};
  String? _focusedCommentId;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_schedulePositionUpdate);
  }

  @override
  void didUpdateWidget(covariant CommentSidebarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_schedulePositionUpdate);
      widget.controller.addListener(_schedulePositionUpdate);
      _schedulePositionUpdate();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_schedulePositionUpdate);
    super.dispose();
  }

  void _schedulePositionUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateCommentPositions();
    });
  }

  void _updateCommentPositions() {
    final anchors = InlineCommentService.scanDocumentAnchors(
      widget.editorState.document,
    );
    final newPositions = <String, double>{};

    for (final entry in anchors.entries) {
      final commentId = entry.key;
      final anchor = entry.value;

      final node = widget.editorState.document.nodeAtPath(anchor.nodePath);
      if (node == null) continue;

      // Get the selectable interface to query cursor rect
      final selectable = node.selectable;
      if (selectable == null) continue;

      final rect = selectable.getCursorRectInPosition(
        Position(path: anchor.nodePath, offset: anchor.startOffset),
      );
      if (rect == null) continue;

      // Convert the local cursor position to global Y using selectable.localToGlobal
      final globalOffset = selectable.localToGlobal(rect.topLeft);
      newPositions[commentId] = globalOffset.dy;
    }

    if (mounted) {
      setState(() {
        _commentTopPositions
          ..clear()
          ..addAll(newPositions);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: widget.child),
        SizedBox(
          width: widget.sidebarWidth,
          child: _buildSidebar(),
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final comments = widget.controller.comments
            .where((c) => _commentTopPositions.containsKey(c.id))
            .toList()
          ..sort(
            (a, b) => _commentTopPositions[a.id]!
                .compareTo(_commentTopPositions[b.id]!),
          );

        if (comments.isEmpty) return const SizedBox.shrink();

        return LayoutBuilder(
          builder: (context, constraints) {
            final sidebarTop = _getSidebarTop(context);
            final positioned = _buildPositionedCards(
              comments,
              sidebarTop,
            );
            return Stack(children: positioned);
          },
        );
      },
    );
  }

  /// Returns the global Y of the top edge of this sidebar widget.
  double _getSidebarTop(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return 0;
    return box.localToGlobal(Offset.zero).dy;
  }

  List<Widget> _buildPositionedCards(
    List<InlineComment> comments,
    double sidebarTop,
  ) {
    double lastBottom = 0;
    const minGap = 8.0;
    const estimatedCardHeight = 80.0;
    final widgets = <Widget>[];

    for (final comment in comments) {
      final globalY = _commentTopPositions[comment.id]!;
      double top = globalY - sidebarTop;
      if (top < lastBottom + minGap) top = lastBottom + minGap;

      widgets.add(
        Positioned(
          top: top,
          left: 8,
          right: 8,
          child: CommentCard(
            comment: comment,
            controller: widget.controller,
            isFocused: _focusedCommentId == comment.id,
            onFocusChanged: (focused) {
              setState(() {
                _focusedCommentId = focused ? comment.id : null;
              });
            },
          ),
        ),
      );

      lastBottom = top + estimatedCardHeight;
    }

    return widgets;
  }
}
