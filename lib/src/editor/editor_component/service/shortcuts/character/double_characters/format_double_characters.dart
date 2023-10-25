import 'package:appflowy_editor/appflowy_editor.dart';

// We currently have only one format style is triggered by double characters.
// **abc** or __abc__ -> bold abc
// If we have more in the future, we should add them in this enum and update the [style] variable in [handleDoubleCharactersFormat].
enum DoubleCharacterFormatStyle {
  bold,
  strikethrough,
}

bool handleFormatByWrappingWithDoubleCharacter({
  // for demonstration purpose, the following comments use * to represent the character from the parameter [char].
  required EditorState editorState,
  required String character,
  required DoubleCharacterFormatStyle formatStyle,
}) {
  assert(character.length == 1);
  final selection = editorState.selection;
  // if the selection is not collapsed or the cursor is at the first three index range, we don't need to format it.
  // we should return false to let the IME handle it.
  if (selection == null || !selection.isCollapsed || selection.end.offset < 4) {
    return false;
  }

  final path = selection.end.path;
  final node = editorState.getNodeAtPath(path);
  final delta = node?.delta;
  // if the node doesn't contain the delta(which means it isn't a text),
  // we don't need to format it.
  if (node == null || delta == null) {
    return false;
  }

  final plainText = delta.toPlainText();

  // The plainText should have at least 4 characters,like **a*.
  // The last char in the plainText should be *[char]. Otherwise, we don't need to format it.
  if (plainText.length < 4 ||
      plainText[selection.end.offset - 1] != character) {
    return false;
  }

  // find all the index of *[char]
  final charIndexList = <int>[];
  for (var i = 0; i < plainText.length; i++) {
    if (plainText[i] == character) {
      charIndexList.add(i);
    }
  }

  if (charIndexList.length < 3) {
    return false;
  }

  // for example: **abc* -> [0, 1, 5]
  // thirdLastCharIndex = 0, secondLastCharIndex = 1, lastCharIndex = 5
  // make sure the third *[char] and second *[char] are connected
  // make sure the second *[char] and last *[char] are split by at least one character
  final thirdLastCharIndex = charIndexList[charIndexList.length - 3];
  final secondLastCharIndex = charIndexList[charIndexList.length - 2];
  final lastCharIndex = charIndexList[charIndexList.length - 1];
  if (secondLastCharIndex != thirdLastCharIndex + 1 ||
      lastCharIndex == secondLastCharIndex + 1) {
    return false;
  }

  // if all the conditions are met, we should format the text.
  // 1. delete all the *[char]
  // 2. update the style of the text surrounded by the double *[char] to [formatStyle]
  // 3. update the cursor position.
  final deletion = editorState.transaction
    ..deleteText(node, lastCharIndex, 1)
    ..deleteText(node, thirdLastCharIndex, 2);
  editorState.apply(deletion);

  // To minimize errors, retrieve the format style from an enum that is specific to double characters.
  final String style;

  switch (formatStyle) {
    case DoubleCharacterFormatStyle.bold:
      style = 'bold';
      break;
    case DoubleCharacterFormatStyle.strikethrough:
      style = 'strikethrough';
      break;
    default:
      style = '';
      assert(false, 'Invalid format style');
  }

  // if the text is already formatted, we should remove the format.
  final sliced = delta.slice(
    thirdLastCharIndex + 2,
    selection.end.offset - 1,
  );
  final result = sliced.everyAttributes((element) => element[style] == true);

  final format = editorState.transaction
    ..formatText(
      node,
      thirdLastCharIndex,
      selection.end.offset - thirdLastCharIndex - 3,
      {
        style: !result,
      },
    )
    ..afterSelection = Selection.collapsed(
      Position(
        path: path,
        offset: selection.end.offset - 3,
      ),
    );
  editorState.apply(format);
  return true;
}
