import 'package:appflowy_editor/appflowy_editor.dart';

const _hyphen = '-';
const _emDash = '—'; // This is an em dash — not a single dash - !!

/// format two hyphens into an em dash
///
/// - support
///   - desktop
///   - mobile
///   - web
///
final CharacterShortcutEvent formatDoubleHyphenEmDash = CharacterShortcutEvent(
  key: 'format double hyphen into an em dash',
  character: _hyphen,
  handler: (editorState) async => handleDoubleCharacterReplacement(
    editorState: editorState,
    character: _hyphen,
    replacement: _emDash,
  ),
);

Future<bool> handleDoubleCharacterReplacement({
  required EditorState editorState,
  required String character,
  required String replacement,
}) async {
  assert(character.length == 1);

  Selection? selection = editorState.selection;
  if (selection == null) {
    return false;
  }

  if (!selection.isCollapsed) {
    await editorState.deleteSelection(selection);
  }

  selection = editorState.selection;
  if (selection == null) {
    return false;
  }

  final node = editorState.getNodeAtPath(selection.end.path);
  final delta = node?.delta;
  if (node == null || delta == null || delta.isEmpty) {
    return false;
  }

  if (selection.end.offset > 0) {
    final plain = delta.toPlainText();

    final previousCharacter = plain[selection.end.offset - 1];
    if (previousCharacter != _hyphen) {
      return false;
    }

    final replace = editorState.transaction
      ..replaceText(
        node,
        selection.end.offset - 1,
        1,
        _emDash,
      );

    await editorState.apply(replace);

    return true;
  }

  return false;
}
