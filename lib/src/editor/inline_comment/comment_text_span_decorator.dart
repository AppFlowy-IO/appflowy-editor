import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'inline_comment.dart';
import 'inline_comment_controller.dart';

/// Applies comment highlight decoration to a [TextInsert] that carries comment ids.
///
/// This function is designed to be used as part of a chained
/// [TextSpanDecoratorForAttribute]. It reads the `comment-ids` attribute,
/// looks up matching [InlineComment] objects from [InlineCommentController],
/// and returns a decorated [TextSpan] with:
///
/// - A background highlight color
/// - An underline in the same color (PDF annotation style)
/// - A [TapGestureRecognizer] that invokes [InlineCommentController.onCommentTapped]
///
/// Returns [before] unchanged when:
/// - The text insert carries no `comment-ids`
/// - No matching [InlineComment] is found in the controller
/// - The controller is not available in the widget tree
///
/// [recognizerProvider] is an optional factory that returns a managed
/// [TapGestureRecognizer] for a given comment-id key. When provided, the
/// caller owns the recognizer lifecycle (creation and disposal). When omitted,
/// a short-lived recognizer is created locally — callers should prefer
/// providing a [recognizerProvider] to avoid memory leaks.
InlineSpan applyCommentDecoration({
  required BuildContext context,
  required Node node,
  required int index,
  required TextInsert textInsert,
  required InlineSpan before,
  required InlineSpan after,
  required InlineCommentController controller,
  TapGestureRecognizer Function(
    String commentId,
    InlineCommentController controller,
    BuildContext context,
  )? recognizerProvider,
}) {
  // 1. Read comment-ids attribute
  final attributes = textInsert.attributes;
  if (attributes == null) return before;

  final rawIds = attributes[AppFlowyRichTextKeys.commentIds];
  if (rawIds == null) return before;

  final List<String> ids;
  if (rawIds is List) {
    ids = rawIds.map((e) => e.toString()).toList();
  } else if (rawIds is String) {
    ids = [rawIds];
  } else {
    return before;
  }

  if (ids.isEmpty) return before;

  // 2. Find valid comments (at least one in the controller)
  final comments = ids
      .map((id) => controller.findById(id))
      .whereType<InlineComment>()
      .toList();

  if (comments.isEmpty) return before;

  // 3. Use the first valid comment's highlight color
  final color = controller.highlightColorFor(comments.first);

  // 4. Build highlighted style
  // `before` may be a TextSpan or WidgetSpan; only operate on TextSpan
  if (before is! TextSpan) return before;

  final existingStyle = before.style ?? const TextStyle();
  final highlightStyle = existingStyle.copyWith(
    backgroundColor: color,
    decoration: TextDecoration.underline,
    decorationColor: color.withValues(alpha: 0.8),
  );

  // 5. TapGestureRecognizer — single tap triggers onCommentTapped.
  // Use the managed recognizer from the provider when available so that the
  // caller (e.g. _InlineCommentServiceWidgetState) can properly dispose it.
  // Fall back to a locally-created recognizer only when no provider is given.
  final TapGestureRecognizer recognizer;
  if (recognizerProvider != null) {
    recognizer = recognizerProvider(comments.first.id, controller, context);
    // Refresh the onTap binding so it captures the current comments list and
    // BuildContext every time the decoration is re-applied.
    recognizer.onTap = () {
      for (final comment in comments) {
        controller.onCommentTapped?.call(comment.id, context);
      }
    };
  } else {
    recognizer = TapGestureRecognizer()
      ..onTap = () {
        for (final comment in comments) {
          controller.onCommentTapped?.call(comment.id, context);
        }
      };
  }

  return TextSpan(
    text: textInsert.text,
    style: highlightStyle,
    recognizer: recognizer,
    mouseCursor: SystemMouseCursors.click,
    children: before.children,
  );
}
