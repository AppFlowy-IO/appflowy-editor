import 'package:appflowy_editor/appflowy_editor.dart';

const _equalGreater = '=>';
const _doubleArrow = '⇒';

/// format '=' + '>' into an ⇒ 
///
/// - support
///   - desktop
///   - mobile
///   - web
///
final CharacterShortcutEvent formatEqualGreaterDoubleArrow = CharacterShortcutEvent(
  key: 'format equals to and greater than into Rightwards double arrow',
  character: _equalGreater,
  handler: (editorState) async => handleEqualDoubleReplacement(
    editorState: editorState,
    character: _equalGreater,
    replacement: _doubleArrow,
  ),
);

Future<bool> handleEqualDoubleReplacement({
  required EditorState editorState,
  required String character,
  required String replacement,
}) async {
  assert(character.isNotEmpty);

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
    if (previousCharacter != _equalGreater) {
      return false;
    }

    final replace = editorState.transaction
      ..replaceText(
        node,
        selection.end.offset - 1,
        1,
        _doubleArrow,
      );

    await editorState.apply(replace);

    return true;
  }

  return false;
}
