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
    (node) => node.type != 'numbered_list',
    (text, selection) {
      final match = _numberRegex.firstMatch(text);
      final matchText = match?.group(0);
      final numberText = match?.group(1);
      return match != null &&
          matchText != null &&
          numberText != null &&
          selection.endIndex == matchText.length;
    },
    (text, node, delta) {
      final match = _numberRegex.firstMatch(text)!;
      final matchText = match.group(0)!;
      return Node(
        type: 'numbered_list',
        attributes: {
          'delta': delta.compose(Delta()..delete(matchText.length)).toJson(),
        },
      );
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
    'numbered_list',
  ),
);
