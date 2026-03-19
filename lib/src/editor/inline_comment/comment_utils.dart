import 'package:appflowy_editor/appflowy_editor.dart';

/// Collects all comment-ids from the delta operations that overlap
/// with [normalizedSelection] in the editor.
///
/// The [normalizedSelection] must be a single-node selection (i.e.
/// [Selection.isSingle] is `true`).  Only delta ops whose character range
/// overlaps `[startIndex, endIndex)` are considered, so comment-ids that
/// exist outside the selected text are not included.
List<String> collectExistingCommentIds(
  EditorState editorState,
  Selection normalizedSelection,
) {
  final existing = <String>{};

  // Only single-node selections are supported (caller should ensure this).
  final node = editorState.getNodeAtPath(normalizedSelection.start.path);
  final delta = node?.delta;
  if (delta == null) return [];

  final startIndex = normalizedSelection.startIndex;
  final endIndex = normalizedSelection.endIndex;

  int offset = 0;
  for (final op in delta) {
    if (op is TextInsert) {
      final opEnd = offset + op.text.length;
      // Only process ops that overlap with the selection range.
      if (offset < endIndex && opEnd > startIndex) {
        final raw = op.attributes?[AppFlowyRichTextKeys.commentIds];
        if (raw is List) {
          existing.addAll(raw.map((e) => e.toString()));
        } else if (raw is String) {
          existing.add(raw);
        }
      }
      offset = opEnd;
    } else {
      offset += 1;
    }
  }

  return existing.toList();
}
