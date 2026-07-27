import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/inline_comment/inline_comment.dart';
import 'package:flutter/material.dart';

/// Called when the user requests to add a comment on the selected text.
///
/// Parameters:
/// - [nodeId]: the id of the [Node] that contains the anchored text.
/// - [startOffset]: delta offset of the selection start within the node.
/// - [endOffset]: delta offset of the selection end within the node.
/// - [initialText]: optional pre-filled comment text.
///
/// Returns the newly created comment id, or null if the operation was
/// cancelled / failed.
typedef OnCommentAdded = Future<String?> Function(
  String nodeId,
  int startOffset,
  int endOffset,
  String? initialText,
);

/// Called when a comment anchor is fully removed from the document
/// (i.e. all text carrying that comment-id has been deleted).
typedef OnCommentDeleted = Future<void> Function(String commentId);

/// Called when the user taps on highlighted text that carries a comment.
///
/// The host app can use this to show a detail sheet, scroll to the comment
/// in a sidebar, etc.
typedef OnCommentTapped = void Function(
  String commentId,
  BuildContext context,
);

/// Controls inline comments displayed in an [AppFlowyEditor].
///
/// The editor **never** stores comment content — it only stores comment ids
/// (anchors) inside the delta attributes. All comment data lives outside the
/// editor and is pushed in via [updateComments] / [updateComment].
///
/// Usage:
/// ```dart
/// final controller = InlineCommentController(
///   onCommentAdded: (nodeId, start, end, _) async {
///     // create comment in your backend, return its id
///     return 'cmt-${uuid()}';
///   },
///   onCommentDeleted: (id) async { /* remove from backend */ },
/// );
///
/// AppFlowyEditor(
///   editorState: editorState,
///   inlineCommentController: controller,
/// );
/// ```
class InlineCommentController extends ChangeNotifier {
  InlineCommentController({
    required this.onCommentAdded,
    required this.onCommentDeleted,
    this.onCommentTapped,
    List<InlineComment>? initialComments,
    this.commentHighlightColorBuilder,
    this.defaultHighlightColor = const Color(0x66FFC107),
  }) : _comments = List<InlineComment>.from(initialComments ?? []);

  // ---------------------------------------------------------------------------
  // Callbacks (set by the host app)
  // ---------------------------------------------------------------------------

  final OnCommentAdded onCommentAdded;
  final OnCommentDeleted onCommentDeleted;
  final OnCommentTapped? onCommentTapped;

  // ---------------------------------------------------------------------------
  // Styling
  // ---------------------------------------------------------------------------

  /// Override per-comment highlight color. Receives the comment and returns
  /// the desired background color. Falls back to [defaultHighlightColor].
  final Color Function(InlineComment comment)? commentHighlightColorBuilder;

  /// Default highlight color applied to text that carries a comment.
  final Color defaultHighlightColor;

  // ---------------------------------------------------------------------------
  // Comment list
  // ---------------------------------------------------------------------------

  List<InlineComment> _comments;

  /// All comments currently known to the editor.
  List<InlineComment> get comments => List.unmodifiable(_comments);

  /// Replace the full comment list (e.g. after a server sync).
  void updateComments(List<InlineComment> comments) {
    _comments = List<InlineComment>.from(comments);
    notifyListeners();
  }

  /// Update a single comment by id, notifying listeners.
  void updateComment(InlineComment comment) {
    final idx = _comments.indexWhere((c) => c.id == comment.id);
    if (idx >= 0) {
      _comments[idx] = comment;
      notifyListeners();
    }
  }

  /// Remove a comment by id, notifying listeners.
  void removeComment(String commentId) {
    final before = _comments.length;
    _comments.removeWhere((c) => c.id == commentId);
    if (_comments.length != before) notifyListeners();
  }

  /// Look up a comment by id; returns null if not found.
  InlineComment? findById(String id) {
    for (final c in _comments) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Returns the highlight color to use for [comment].
  Color highlightColorFor(InlineComment comment) =>
      commentHighlightColorBuilder?.call(comment) ?? defaultHighlightColor;
}
