import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:collection/collection.dart';

enum FormatStyleByWrappingWithSingleChar {
  code,
  italic,
  strikethrough,
}

class CheckSingleFormatFormatResult {
  CheckSingleFormatFormatResult({
    required this.node,
    required this.lastCharIndex,
    required this.path,
    required this.delta,
  });

  final Node node;
  final int lastCharIndex;
  final Path path;
  final Delta delta;
}

/// Check if the single character format should be applied.
///
/// It's helpful for the IME to check if the single character format should be applied.
/// // The selection is not only the editorState.selection, you can pass any selection in line to check every node in the selection.
(bool, CheckSingleFormatFormatResult?)
    checkSingleCharacterFormatShouldBeApplied({
  required EditorState editorState,
  required Selection selection,
  required String character,
  required FormatStyleByWrappingWithSingleChar formatStyle,
}) {
  if (character.length != 1) {
    AppFlowyEditorLog.input.debug('character length is not 1');
    return (false, null);
  }

// If the selection is not collapsed or the cursor is at the first two index range, we don't need to format it.
  // We should return false to let the IME handle it.
  if (!selection.isCollapsed || selection.end.offset < 2) {
    AppFlowyEditorLog.input.debug('selection is not valid');
    return (false, null);
  }

  final path = selection.end.path;
  final node = editorState.getNodeAtPath(path);
  final delta = node?.delta;
  // If the node doesn't contain the delta(which means it isn't a text), we don't need to format it.
  if (node == null || delta == null) {
    return (false, null);
  }

  // find the last inline code attributes
  final lastInlineCode = delta.indexed.lastWhereOrNull((element) {
    final (_, op) = element;
    if (op.attributes?[AppFlowyRichTextKeys.code] == true) {
      return true;
    }
    return false;
  });
  int startIndex = 0;
  if (lastInlineCode != null &&
      formatStyle != FormatStyleByWrappingWithSingleChar.code) {
    final (lastInlineCodeIndex, _) = lastInlineCode;
    startIndex = delta.indexed.fold(0, (sum, element) {
      final (index, op) = element;
      if (index <= lastInlineCodeIndex) {
        return sum + op.length;
      }
      return sum;
    });
  }

  if (startIndex >= selection.end.offset) {
    return (false, null);
  }

  final plainText = delta.toPlainText().substring(
        startIndex,
        selection.end.offset,
      );
  final lastCharIndex = plainText.lastIndexOf(character);
  final textAfterLastChar = plainText.substring(lastCharIndex + 1);
  bool textAfterLastCharIsEmpty = textAfterLastChar.trim().isEmpty;

  // The following conditions won't trigger the single character formatting:
  // 1. There is no 'Character' in the plainText: lastIndexOf returns -1.
  if (lastCharIndex == -1) {
    return (false, null);
  }
  // 2. The text after last char is empty or only contains spaces.
  if (textAfterLastCharIsEmpty) {
    return (false, null);
  }

  // 3. If it is in a double character case, we should skip the single character formatting.
  // For example, adding * after **a*, it should skip the single character formatting and it will be handled by double character formatting.
  if ((character == '*' || character == '_' || character == '~') &&
      (lastCharIndex >= 1) &&
      (plainText[lastCharIndex - 1] == character)) {
    return (false, null);
  }

  // 4. If the last character index is greater that current cursor position, we should skip the single character formatting.
  if (lastCharIndex >= selection.end.offset) {
    return (false, null);
  }

  // 5. If the text inbetween is empty (continuous)
  final rawPlainText = delta.toPlainText();
  if (rawPlainText
      .substring(startIndex + lastCharIndex + 1, selection.end.offset)
      .isEmpty) {
    return (false, null);
  }

  return (
    true,
    CheckSingleFormatFormatResult(
      node: node,
      lastCharIndex: startIndex + lastCharIndex,
      path: path,
      delta: delta,
    )
  );
}

bool handleFormatByWrappingWithSingleCharacter({
  required EditorState editorState,
  required String character,
  required FormatStyleByWrappingWithSingleChar formatStyle,
}) {
  final selection = editorState.selection;
  if (selection == null) {
    return false;
  }

  final (shouldApply, formatResult) = checkSingleCharacterFormatShouldBeApplied(
    editorState: editorState,
    selection: selection,
    character: character,
    formatStyle: formatStyle,
  );

  if (!shouldApply || formatResult == null) {
    AppFlowyEditorLog.input.debug('format single character failed');
    return false;
  }

  final node = formatResult.node;
  final lastCharIndex = formatResult.lastCharIndex;
  final delta = formatResult.delta;
  final path = formatResult.path;

  // Before deletion we need to insert the character in question so that undo manager
  // will undo only the style applied and keep the character.
  final insertion = editorState.transaction
    ..insertText(node, selection.end.offset, character)
    ..afterSelection = Selection.collapsed(
      selection.end.copyWith(offset: selection.end.offset + 1),
    );
  editorState.apply(insertion, skipHistoryDebounce: true);

  // If none of the above exclusive conditions are satisfied, we should format the text to [formatStyle].
  // 1. Delete the previous 'Character'.
  // 2. Update the style of the text surrounded by the two 'Character's to [formatStyle].
  // 3. Update the cursor position.
  final deletion = editorState.transaction
    ..deleteText(node, lastCharIndex, 1)
    ..deleteText(node, selection.end.offset - 1, 1);
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
  }

  // if the text is already formatted, we should remove the format.
  final sliced = delta.slice(lastCharIndex + 1, selection.end.offset);
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
