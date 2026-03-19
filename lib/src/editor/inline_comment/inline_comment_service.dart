import 'dart:async';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/inline_comment/inline_comment_controller.dart';

/// Anchors a comment to a position in the document.
///
/// Records the [nodePath] of the [Node] and the [startOffset] within
/// that node's delta where the comment first appears.
class CommentAnchor {
  const CommentAnchor({
    required this.nodePath,
    required this.startOffset,
  });

  final Path nodePath;
  final int startOffset;
}

/// Listens to the [EditorState] transaction stream and notifies the
/// [InlineCommentController] when a comment anchor is fully removed from
/// the document (i.e. all text carrying that comment-id has been deleted).
class InlineCommentService {
  InlineCommentService({
    required this.editorState,
    required this.controller,
  }) {
    _subscription = editorState.transactionStream.listen(_onTransaction);
  }

  final EditorState editorState;
  final InlineCommentController controller;
  late final StreamSubscription<EditorTransactionValue> _subscription;

  void dispose() {
    _subscription.cancel();
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Scans the entire document delta and returns a mapping from comment id to
  /// its first anchor position (nodePath + startOffset within that node's delta).
  Map<String, CommentAnchor> scanAnchors() {
    final result = <String, CommentAnchor>{};
    _visitAllNodes(editorState.document.root, (node) {
      final delta = node.delta;
      if (delta == null) return;

      int offset = 0;
      for (final op in delta) {
        if (op is TextInsert) {
          final attrs = op.attributes;
          if (attrs != null && attrs.containsKey('comment-ids')) {
            final raw = attrs['comment-ids'];
            final ids = _extractCommentIds(raw);
            for (final id in ids) {
              // Only record the first occurrence.
              result.putIfAbsent(
                id,
                () => CommentAnchor(
                  nodePath: node.path,
                  startOffset: offset,
                ),
              );
            }
          }
          offset += op.length;
        } else {
          offset += op.length;
        }
      }
    });
    return result;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  void _visitAllNodes(Node node, void Function(Node) visitor) {
    for (final child in node.children) {
      visitor(child);
      if (child.children.isNotEmpty) {
        _visitAllNodes(child, visitor);
      }
    }
  }

  /// Extract a `List<String>` of comment ids from the attribute value, which
  /// may be stored as a `List<dynamic>` or a plain `String`.
  List<String> _extractCommentIds(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    } else if (raw is String) {
      return [raw];
    }
    return [];
  }

  void _onTransaction(EditorTransactionValue value) {
    final (time, _, options) = value;
    // options not used beyond destructuring.
    if (time != TransactionTime.after) return;

    // After every transaction, collect the comment ids still present in the
    // document and compare against the controller's known comment list.
    // Any id that is in the controller but no longer in the document has been
    // fully deleted.
    final anchors = scanAnchors();
    final existingIds = anchors.keys.toSet();

    for (final comment in List.of(controller.comments)) {
      if (!existingIds.contains(comment.id)) {
        // Notify the host application and remove from the controller's list.
        controller.onCommentDeleted(comment.id);
        controller.removeComment(comment.id);
      }
    }
  }
}
