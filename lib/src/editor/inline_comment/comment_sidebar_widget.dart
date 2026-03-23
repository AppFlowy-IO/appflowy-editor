import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'inline_comment.dart';
import 'inline_comment_controller.dart';
import 'inline_comment_service.dart';
import 'comment_card_widget.dart';

/// Desktop sidebar that displays all [InlineComment]s in document order.
///
/// Uses [InlineCommentService.scanDocumentAnchors] to determine each comment's
/// order by its text position, then renders cards in a scrollable column.
class CommentSidebarWidget extends StatefulWidget {
  const CommentSidebarWidget({
    super.key,
    required this.editorState,
    required this.controller,
    this.sidebarWidth = 240.0,
  });

  final EditorState editorState;
  final InlineCommentController controller;

  /// Width of the sidebar in logical pixels.
  final double sidebarWidth;

  @override
  State<CommentSidebarWidget> createState() => _CommentSidebarWidgetState();
}

class _CommentSidebarWidgetState extends State<CommentSidebarWidget> {
  List<String> _orderedCommentIds = [];
  String? _focusedCommentId;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onCommentsChanged);
    _updateOrder();
  }

  @override
  void didUpdateWidget(covariant CommentSidebarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_onCommentsChanged);
      widget.controller.addListener(_onCommentsChanged);
    }
    _updateOrder();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onCommentsChanged);
    super.dispose();
  }

  void _onCommentsChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateOrder();
        setState(() {});
      }
    });
  }

  void _updateOrder() {
    final anchors = InlineCommentService.scanDocumentAnchors(
      widget.editorState.document,
    );
    // Sort comment ids by their document position (path then offset).
    final sortedIds = anchors.entries.toList()
      ..sort((a, b) {
        final pathCmp = _comparePaths(a.value.nodePath, b.value.nodePath);
        if (pathCmp != 0) return pathCmp;
        return a.value.startOffset.compareTo(b.value.startOffset);
      });
    _orderedCommentIds = sortedIds.map((e) => e.key).toList();
  }

  int _comparePaths(List<int> a, List<int> b) {
    for (int i = 0; i < a.length && i < b.length; i++) {
      if (a[i] != b[i]) return a[i].compareTo(b[i]);
    }
    return a.length.compareTo(b.length);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: widget.sidebarWidth,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: _buildSidebar(),
    );
  }

  Widget _buildSidebar() {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        // Filter to comments that exist in both the controller and the document.
        final comments = _orderedCommentIds
            .map((id) => widget.controller.findById(id))
            .whereType<InlineComment>()
            .toList();

        if (comments.isEmpty) return const SizedBox.shrink();

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < comments.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                CommentCard(
                  comment: comments[i],
                  controller: widget.controller,
                  isFocused: _focusedCommentId == comments[i].id,
                  onFocusChanged: (focused) {
                    setState(() {
                      _focusedCommentId = focused ? comments[i].id : null;
                    });
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
