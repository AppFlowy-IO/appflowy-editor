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
  // If the selection is not collapsed or the cursor is at the first two index range, we don't need to format it.
  // We should return false to let the IME handle it.
  if (selection == null || !selection.isCollapsed || selection.end.offset < 2) {
    return false;
  }

  final path = selection.end.path;
  final node = editorState.getNodeAtPath(path);
  final delta = node?.delta;
  // If the node doesn't contain the delta(which means it isn't a text), we don't need to format it.
  if (node == null || delta == null) {
    return false;
  }

  final plainText = delta.toPlainText();
  final lastCharIndex = plainText.lastIndexOf(character);
  final textAfterLastChar = plainText.substring(lastCharIndex + 1);
  bool textAfterLastCharIsEmpty = textAfterLastChar.trim().isEmpty;

  // The following conditions won't trigger the single character formatting:
  // 1. There is no 'Character' in the plainText: lastIndexOf returns -1.
  if (lastCharIndex == -1) {
    return false;
  }
  // 2. The text after last char is empty or only contains spaces.
  if (textAfterLastCharIsEmpty) {
    return false;
  }

  // 3. If it is in a double character case, we should skip the single character formatting.
  // For example, adding * after **a*, it should skip the single character formatting and it will be handled by double character formatting.
  if ((character == '*' || character == '_' || character == '~') &&
      (lastCharIndex >= 1) &&
      (plainText[lastCharIndex - 1] == character)) {
    return false;
  }

  // If none of the above exclusive conditions are satisfied, we should format the text to [formatStyle].
  // 1. Delete the previous 'Character'.
  // 2. Update the style of the text surrounded by the two 'Character's to [formatStyle].
  // 3. Update the cursor position.

  final deletion = editorState.transaction
    ..deleteText(
      node,
      lastCharIndex,
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
    lastCharIndex + 1,
    selection.end.offset,
  );
  final result = sliced.everyAttributes((element) => element[style] == true);

  final format = editorState.transaction
    ..formatText(
      node,
      lastCharIndex,
      selection.end.offset - lastCharIndex - 1,
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
