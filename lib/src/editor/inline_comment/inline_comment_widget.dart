import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'inline_comment_service.dart';
import 'comment_text_span_decorator.dart';

/// A wrapper widget that adds inline comment support to [AppFlowyEditor].
///
/// Place this widget **around** [AppFlowyEditor] instead of modifying the
/// editor itself. The editor remains completely unaware of comments.
///
/// Usage:
/// ```dart
/// InlineCommentWidget(
///   editorState: editorState,
///   controller: myController,
///   showSidebar: true,
///   child: AppFlowyEditor(
///     editorState: editorState,
///     floatingToolbarItems: [
///       ...standardFloatingToolbarItems,
///       buildCommentToolbarItem(myController),
///     ],
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
  TextSpanDecoratorForAttribute? _previousDecorator;
  final Map<String, TapGestureRecognizer> _recognizers = {};

  @override
  void initState() {
    super.initState();
    _service = InlineCommentService(
      editorState: widget.editorState,
      controller: widget.controller,
    );
    widget.controller.addListener(_onControllerChanged);
    _installDecorator();
  }

  @override
  void didUpdateWidget(covariant InlineCommentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final editorChanged = widget.editorState != oldWidget.editorState;
    final controllerChanged = widget.controller != oldWidget.controller;

    if (editorChanged || controllerChanged) {
      oldWidget.controller.removeListener(_onControllerChanged);
      _service.dispose();
      _restoreDecorator();
      _disposeRecognizers();

      _service = InlineCommentService(
        editorState: widget.editorState,
        controller: widget.controller,
      );
      widget.controller.addListener(_onControllerChanged);
      _installDecorator();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _service.dispose();
    _restoreDecorator();
    _disposeRecognizers();
    super.dispose();
  }

  void _onControllerChanged() {
    _disposeRecognizers();
  }

  void _disposeRecognizers() {
    for (final r in _recognizers.values) {
      r.dispose();
    }
    _recognizers.clear();
  }

  TapGestureRecognizer _getOrCreateRecognizer(
    String commentId,
    InlineCommentController controller,
    BuildContext context,
  ) {
    return _recognizers.putIfAbsent(commentId, TapGestureRecognizer.new);
  }

  void _installDecorator() {
    _previousDecorator = widget.editorState.editorStyle.textSpanDecorator;
    widget.editorState.editorStyle = widget.editorState.editorStyle.copyWith(
      textSpanDecorator: _buildChainedDecorator(
        _previousDecorator,
        widget.controller,
      ),
    );
  }

  void _restoreDecorator() {
    widget.editorState.editorStyle = widget.editorState.editorStyle.copyWith(
      textSpanDecorator: _previousDecorator,
    );
  }

  TextSpanDecoratorForAttribute _buildChainedDecorator(
    TextSpanDecoratorForAttribute? existing,
    InlineCommentController controller,
  ) {
    return (context, node, index, textInsert, before, after) {
      // First, run the previously installed decorator (if any).
      final intermediate =
          existing?.call(context, node, index, textInsert, before, after) ??
              before;

      // Then apply comment decoration on top.
      // `intermediate` may be an InlineSpan (e.g. a WidgetSpan) that is not a
      // TextSpan. In that case, skip the comment decorator to avoid a cast
      // error.
      if (intermediate is! TextSpan) return intermediate;
      return applyCommentDecoration(
        context: context,
        node: node,
        index: index,
        textInsert: textInsert,
        before: intermediate,
        after: after,
        controller: controller,
        recognizerProvider: _getOrCreateRecognizer,
      );
    };
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
