import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/inline_comment/comment_text_span_decorator.dart';
import 'package:appflowy_editor/src/editor/inline_comment/inline_comment_controller.dart';
import 'package:appflowy_editor/src/editor/inline_comment/inline_comment_service.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// InlineCommentScope — InheritedWidget
// ---------------------------------------------------------------------------

/// Provides [InlineCommentController] to the sub-tree.
///
/// Use [InlineCommentScope.of] to obtain the controller from any descendant
/// widget.
class InlineCommentScope extends InheritedWidget {
  const InlineCommentScope({
    super.key,
    required this.controller,
    required super.child,
  });

  final InlineCommentController controller;

  /// Returns the nearest [InlineCommentController] in the widget tree, or
  /// `null` if [InlineCommentScope] has not been installed.
  static InlineCommentController? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<InlineCommentScope>()
        ?.controller;
  }

  @override
  bool updateShouldNotify(InlineCommentScope oldWidget) =>
      controller != oldWidget.controller;
}

// ---------------------------------------------------------------------------
// InlineCommentServiceWidget — StatefulWidget
// ---------------------------------------------------------------------------

/// Wraps the editor widget tree to:
/// 1. Start an [InlineCommentService] that monitors deleted comment anchors.
/// 2. Chain a comment decorator into [EditorStyle.textSpanDecorator].
/// 3. Expose [InlineCommentController] to descendants via [InlineCommentScope].
class InlineCommentServiceWidget extends StatefulWidget {
  const InlineCommentServiceWidget({
    super.key,
    required this.editorState,
    required this.controller,
    required this.child,
  });

  final EditorState editorState;
  final InlineCommentController controller;
  final Widget child;

  @override
  State<InlineCommentServiceWidget> createState() =>
      _InlineCommentServiceWidgetState();
}

class _InlineCommentServiceWidgetState
    extends State<InlineCommentServiceWidget> {
  late InlineCommentService _service;
  TextSpanDecoratorForAttribute? _previousDecorator;

  @override
  void initState() {
    super.initState();
    _service = InlineCommentService(
      editorState: widget.editorState,
      controller: widget.controller,
    );
    _installDecorator();
  }

  @override
  void didUpdateWidget(covariant InlineCommentServiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final editorStateChanged = widget.editorState != oldWidget.editorState;
    final controllerChanged = widget.controller != oldWidget.controller;

    if (editorStateChanged || controllerChanged) {
      // Clean up the old service and decorator.
      _service.dispose();
      _restoreDecorator();

      // Rebuild service and decorator for the new editorState/controller.
      _service = InlineCommentService(
        editorState: widget.editorState,
        controller: widget.controller,
      );
      _previousDecorator = widget.editorState.editorStyle.textSpanDecorator;
      _installDecorator();
    }
  }

  @override
  void dispose() {
    _service.dispose();
    _restoreDecorator();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Decorator chaining
  // ---------------------------------------------------------------------------

  void _installDecorator() {
    _previousDecorator = widget.editorState.editorStyle.textSpanDecorator;
    final chained = _buildChainedDecorator(
      _previousDecorator,
      widget.controller,
    );
    widget.editorState.editorStyle =
        widget.editorState.editorStyle.copyWith(textSpanDecorator: chained);
  }

  void _restoreDecorator() {
    widget.editorState.editorStyle = widget.editorState.editorStyle
        .copyWith(textSpanDecorator: _previousDecorator);
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
      if (intermediate is TextSpan) {
        return applyCommentDecoration(
          context: context,
          node: node,
          index: index,
          textInsert: textInsert,
          before: intermediate,
          after: after,
          controller: controller,
        );
      }
      return intermediate;
    };
  }

  @override
  Widget build(BuildContext context) {
    return InlineCommentScope(
      controller: widget.controller,
      child: widget.child,
    );
  }
}
