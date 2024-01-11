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
  final lastCharIndex = plainText.lastIndexOf(character);

  /// triggerChar is the character that triggers the formatting.
  /// for example, add '_'(triggerChar) after '_abc', it doesn't belong to the plainText.
  final triggerCharIndex = selection.end.offset;
  final textAfterLastChar = plainText.substring(
    lastCharIndex + 1,
  );
  bool isFullOfSpaces = textAfterLastChar.trim().isEmpty;

  // The following conditions are not supposed to trigger formatting:
  // 1. This is no 'Character' in the plainText: lastIndexOf returns -1.
  // 2. There are two characters connecting together, like adding '_' after 'abc_' won't trigger formatting.
  // 3. The text between the last char and trigger char are all spaces. For example, adding '_' after '_abc_ ' won't trigger formatting.
  // Note since we support using '\' to escape the character,it could be possible that multiple shortcut characters exist in the plainText.
  // We should only format the last one. like adding '_' after '\_abc\_ _123' should format the text to '123'
  // 4. If the character before the last 'Character' is the same as the 'Character', we don't need to format it in single character case.
  // For example, adding * after **a*, it skips the single character formatting and it will be handled by double character formatting.
  if (lastCharIndex == -1 ||
      lastCharIndex + 1 == triggerCharIndex ||
      isFullOfSpaces ||
      plainText[lastCharIndex - 1] == character) {
    return false;
  }

  // if all the conditions are met, we should format the text to italic.
  // 1. delete the previous 'Character',
  // 2. update the style of the text surrounded by the two 'Character's to [formatStyle]
  // 3. update the cursor position.

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
