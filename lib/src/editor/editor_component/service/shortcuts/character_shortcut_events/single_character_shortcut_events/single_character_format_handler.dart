import 'package:appflowy_editor/appflowy_editor.dart';

enum SingleCharacterFormatStyle {
  code,
  italic,
  strikethrough,
}

Future<bool> Function(EditorState) handleSingleCharacterFormat({
  required String char,
  required SingleCharacterFormatStyle formatStyle,
}) {
  assert(char.length == 1);
  return (editorState) async {
    final selection = editorState.selection;
    // if the selection is not collapsed,
    // we should return false to let the IME handle it.
    if (selection == null || !selection.isCollapsed) {
      return false;
    }

    final path = selection.end.path;
    final node = editorState.getNodeAtPath(path);
    final delta = node?.delta;
    // if the node doesn't contain the delta(which means it isn't a text)
    // we don't need to format it.
    if (node == null || delta == null) {
      return false;
    }

    final plainText = delta.toPlainText();

    final headCharIndex = plainText.indexOf(char);
    final endCharIndex = plainText.lastIndexOf(char);

    // Determine if a 'Character' already exists in the node and only once.
    // 1. This is no 'Character' in the plainText: indexOf returns -1.
    // 2. More than one 'Character' in the plainText: the headCharIndex and endCharIndex are supposed to be the same, if not, which means plainText has more than one character. For example: when plainText is '_abc', it will trigger formatting(remind:the last char is used to trigger the formatting,so it won't be counted in the plainText.). But adding '_' after 'a__ab' won't trigger formatting.
    // 3. there're two characters connecting together, like adding '_' after 'abc_' won't trigger formatting.
    if (headCharIndex == -1 ||
        headCharIndex != endCharIndex ||
        headCharIndex == selection.end.offset - 1) {
      return false;
    }

    // if all the conditions are met, we should format the text to italic.
    // 1. delete the previous 'Character',
    // 2. update the style of the text surrounded by the two 'Character's to [formatStyle]
    // 3. update the cursor position.

    final deletion = editorState.transaction
      ..deleteText(
        node,
        headCharIndex,
        char.length,
      );
    editorState.apply(deletion);

    // To minimize errors, retrieve the format style from an enum that is specific to single characters.
    final String style;

    switch (formatStyle) {
      case SingleCharacterFormatStyle.code:
        style = 'code';
        break;
      case SingleCharacterFormatStyle.italic:
        style = 'italic';
        break;
      case SingleCharacterFormatStyle.strikethrough:
        style = 'strikethrough';
        break;
      default:
        style = '';
        assert(false, 'Invalid format style');
    }

    final format = editorState.transaction
      ..formatText(
        node,
        headCharIndex,
        selection.end.offset - headCharIndex - 1,
        {
          style: true,
        },
      )
      ..afterSelection = Selection.collapsed(
        Position(
          path: path,
          offset: selection.end.offset - 1,
        ),
      );
    editorState.apply(format);
    return true;
  };
}
