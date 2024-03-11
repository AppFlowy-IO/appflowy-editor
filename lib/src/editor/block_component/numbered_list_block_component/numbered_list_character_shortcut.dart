import 'package:appflowy_editor/appflowy_editor.dart';

final _numberRegex = RegExp(r'^(\d+)\.');

/// Convert 'num. ' to bulleted list
///
/// - support
///   - desktop
///   - mobile
///   - web
///
CharacterShortcutEvent formatNumberToNumberedList = CharacterShortcutEvent(
  key: 'format number to numbered list',
  character: ' ',
  handler: (editorState) async => await formatMarkdownSymbol(
    editorState,
    (node) => node.type != NumberedListBlockKeys.type,
    (node, text, selection) {
      // if the current node is a heading block, we should not convert it to a numbered list
      if (node.type == HeadingBlockKeys.type) {
        return false;
      }
      final match = _numberRegex.firstMatch(text);
      if (match == null) return false;

      final matchText = match.group(0);
      final numberText = match.group(1);
      if (matchText == null || numberText == null) return false;

      // if the previous one is numbered list,
      // we should check the current number is the next number of the previous one
      Node? previous = node.previous;
      int level = 0;
      int? startNumber;
      while (previous != null && previous.type == NumberedListBlockKeys.type) {
        startNumber = previous.attributes[NumberedListBlockKeys.number] as int?;
        level++;
        previous = previous.previous;
      }
      if (startNumber != null) {
        final currentNumber = int.tryParse(numberText);
        if (currentNumber == null || currentNumber != startNumber + level) {
          return false;
        }
      }

      return selection.endIndex == matchText.length;
    },
    (text, node, delta) {
      final match = _numberRegex.firstMatch(text)!;
      final matchText = match.group(0)!;
      final number = matchText.substring(0, matchText.length - 1);
      return [
        node.copyWith(
          type: NumberedListBlockKeys.type,
          attributes: {
            NumberedListBlockKeys.delta:
                delta.compose(Delta()..delete(matchText.length)).toJson(),
            NumberedListBlockKeys.number: int.tryParse(number),
          },
        ),
      ];
    },
  ),
);

/// Insert a new block after the numbered list block.
///
/// - support
///   - desktop
///   - web
///   - mobile
///
CharacterShortcutEvent insertNewLineAfterNumberedList = CharacterShortcutEvent(
  key: 'insert new block after numbered list',
  character: '\n',
  handler: (editorState) async => await insertNewLineInType(
    editorState,
    NumberedListBlockKeys.type,
  ),
);
