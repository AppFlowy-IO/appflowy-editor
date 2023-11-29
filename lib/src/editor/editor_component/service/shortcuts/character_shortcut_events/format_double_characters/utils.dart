import 'package:appflowy_editor/appflowy_editor.dart';

/// If [prefixCharacter] is null or empty, [character] is used
Future<bool> handleDoubleCharacterReplacement({
  required EditorState editorState,
  required String character,
  required String replacement,
  String? prefixCharacter,
}) async {
  assert(character.length == 1);

  Selection? selection = editorState.selection;
  if (selection == null) {
    return false;
  }

  if (!selection.isCollapsed) {
    await editorState.deleteSelection(selection);
  }

  final node = editorState.getNodeAtPath(selection.end.path);
  final delta = node?.delta;
  if (node == null || delta == null || delta.isEmpty) {
    return false;
  }

  if (selection.end.offset > 0) {
    final plain = delta.toPlainText();

    final expectedPrevious =
        prefixCharacter?.isEmpty ?? true ? character : prefixCharacter;

    final previousCharacter = plain[selection.end.offset - 1];
    if (previousCharacter != expectedPrevious) {
      return false;
    }

    final replace = editorState.transaction
      ..replaceText(
        node,
        selection.end.offset - 1,
        1,
        replacement,
      );

    await editorState.apply(replace);

    return true;
  }

  return false;
}
