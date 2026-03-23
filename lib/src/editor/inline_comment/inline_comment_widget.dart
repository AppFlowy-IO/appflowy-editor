import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'inline_comment_service.dart';

/// A wrapper widget that adds inline comment support to [AppFlowyEditor].
///
/// Place this widget **around** [AppFlowyEditor] instead of modifying the
/// editor itself. The editor remains completely unaware of comments.
///
/// **Important:** To render comment highlights the caller must pass a
/// [buildCommentTextSpanDecorator] as the `textSpanDecorator` of the
/// [EditorStyle] supplied to [AppFlowyEditor]. This widget no longer
/// monkey-patches the decorator at runtime, which avoids the bug where
/// `AppFlowyEditor._updateValues()` would overwrite the decorator.
///
/// Usage:
/// ```dart
/// InlineCommentWidget(
///   editorState: editorState,
///   controller: myController,
///   showSidebar: true,
///   child: AppFlowyEditor(
///     editorState: editorState,
///     editorStyle: EditorStyle.desktop(
///       textSpanDecorator: buildCommentTextSpanDecorator(
///         controller: myController,
///       ),
///     ),
///   ),
/// )
/// ```
class InlineCommentWidget extends StatefulWidget {
  const InlineCommentWidget({
    super.key,
    required this.editorState,
    required this.controller,
    required this.child,
    this.showSidebar = false,
    this.sidebarWidth = 240.0,
  });

  final EditorState editorState;
  final InlineCommentController controller;

  /// The [AppFlowyEditor] (or any other widget) to wrap.
  final Widget child;

  /// Whether to show the comment sidebar to the right of the editor.
  ///
  /// Defaults to `false`. Only meaningful on desktop platforms.
  final bool showSidebar;

  /// Width of the comment sidebar in logical pixels.
  ///
  /// Defaults to `240.0`. Ignored when [showSidebar] is `false`.
  final double sidebarWidth;

  @override
  State<InlineCommentWidget> createState() => _InlineCommentWidgetState();
}

class _InlineCommentWidgetState extends State<InlineCommentWidget> {
  late InlineCommentService _service;

  @override
  void initState() {
    super.initState();
    _service = InlineCommentService(
      editorState: widget.editorState,
      controller: widget.controller,
    );
  }

  @override
  void didUpdateWidget(covariant InlineCommentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.editorState != oldWidget.editorState ||
        widget.controller != oldWidget.controller) {
      _service.dispose();
      _service = InlineCommentService(
        editorState: widget.editorState,
        controller: widget.controller,
      );
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showSidebar) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: widget.child),
          CommentSidebarWidget(
            editorState: widget.editorState,
            controller: widget.controller,
            sidebarWidth: widget.sidebarWidth,
          ),
        ],
      );
    }
    return widget.child;
  }
}
