import 'package:appflowy_editor/appflowy_editor.dart';

const _greater = '>';
const _equals = '=';
const _arrow = '⇒'; 

// /// format '=' + '>' into an ⇒ 
// ///
// /// - support
// ///   - desktop
// ///   - mobile
// ///   - web
// ///
final CharacterShortcutEvent formatGreaterEqual = CharacterShortcutEvent(
  key: 'format = + > into ⇒',
  character: _greater,
  handler: (editorState) async => handleEqualGreaterReplacement(
    editorState: editorState,
    character: _greater,
    replacement: _arrow,
  ),
);

// TODO(Xazin): Combine two character replacement methods into
//  a helper function
Future<bool> handleEqualGreaterReplacement({
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
    if (previousCharacter != _equals) {
      return false;
    }

    final replace = editorState.transaction
      ..replaceText(
        node,
        selection.end.offset - 1,
        1,
        _arrow,
      );

    await editorState.apply(replace);

    return true;
  }

  return false;
}