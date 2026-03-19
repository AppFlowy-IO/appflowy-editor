/// An inline comment anchored to a text range in the document.
///
/// The editor stores only [id] inside the delta attributes
/// (`comment-ids` key). All comment content is managed externally
/// (e.g. by the AppFlowy app) and passed in via [InlineCommentController].
class InlineComment {
  const InlineComment({
    required this.id,
    required this.content,
    required this.authorName,
    required this.createdAt,
    this.isResolved = false,
    this.metadata,
  });

  final String id;
  final String content;
  final String authorName;
  final DateTime createdAt;
  final bool isResolved;
  final Map<String, dynamic>? metadata;

  InlineComment copyWith({
    String? id,
    String? content,
    String? authorName,
    DateTime? createdAt,
    bool? isResolved,
    Map<String, dynamic>? metadata,
  }) {
    return InlineComment(
      id: id ?? this.id,
      content: content ?? this.content,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      isResolved: isResolved ?? this.isResolved,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InlineComment &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
