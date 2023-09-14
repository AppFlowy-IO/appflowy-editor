import 'package:appflowy_editor/appflowy_editor.dart';

enum FormatStyleByWrappingWithSingleChar {
  code,
  italic,
  strikethrough,
}

bool handleFormatByWrappingWithSingleCharacter({
  required EditorState editorState,
  required String character,
  required FormatStyleByWrappingWithSingleChar formatStyle,
}) {
  assert(character.length == 1);

  final selection = editorState.selection;
  // if the selection is not collapsed or the cursor is at the first two index range, we don't need to format it.
  // we should return false to let the IME handle it.
  if (selection == null || !selection.isCollapsed || selection.end.offset < 2) {
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

  final headCharIndex = plainText.indexOf(character);
  final endCharIndex = plainText.lastIndexOf(character);

  // Determine if a 'Character' already exists in the node and only once.
  // 1. This is no 'Character' in the plainText: indexOf returns -1.
  // 2. More than one 'Character' in the plainText: the headCharIndex and endCharIndex are supposed to be the same, if not, which means plainText has more than one character. For example: when plainText is '_abc', it will trigger formatting(remind:the last char is used to trigger the formatting,so it won't be counted in the plainText.). But adding '_' after 'a__ab' won't trigger formatting.
  // 3. there are two characters connecting together, like adding '_' after 'abc_' won't trigger formatting.
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
      1,
    );
  editorState.apply(deletion);

  // To minimize errors, retrieve the format style from an enum that is specific to single characters.
  final String style;

  switch (formatStyle) {
    case FormatStyleByWrappingWithSingleChar.code:
      style = 'code';
      break;
    case FormatStyleByWrappingWithSingleChar.italic:
      style = 'italic';
      break;
    case FormatStyleByWrappingWithSingleChar.strikethrough:
      style = 'strikethrough';
      break;
    default:
      style = '';
      assert(false, 'Invalid format style');
  }

  // if the text is already formatted, we should remove the format.
  final sliced = delta.slice(
    headCharIndex + 1,
    selection.end.offset,
  );
  final result = sliced.everyAttributes((element) => element[style] == true);

  final format = editorState.transaction
    ..formatText(
      node,
      headCharIndex,
      selection.end.offset - headCharIndex - 1,
      {
        style: !result,
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
}
