import 'package:appflowy_editor/appflowy_editor.dart';

/// Convert '* ' to bulleted list
///
/// - support
///   - desktop
///   - mobile
///   - web
///
CharacterShortcutEvent formatAsteriskToBulletedList = CharacterShortcutEvent(
  key: 'format asterisk to bulleted list',
  character: ' ',
  handler: (editorState) async =>
      await _formatSymbolToBulletedList(editorState, '*'),
);

/// Convert '- ' to bulleted list
///
/// - support
///   - desktop
///   - mobile
///   - web
///
CharacterShortcutEvent formatMinusToBulletedList = CharacterShortcutEvent(
  key: 'format minus to bulleted list',
  character: ' ',
  handler: (editorState) async =>
      await _formatSymbolToBulletedList(editorState, '-'),
);

/// Insert a new block after the bulleted list block.
///
/// - support
///   - desktop
///   - web
///   - mobile
///
CharacterShortcutEvent insertNewLineAfterBulletedList = CharacterShortcutEvent(
  key: 'insert new block after bulleted list',
  character: '\n',
  handler: (editorState) async => await insertNewLineInType(
    editorState,
    'bulleted_list',
  ),
);

// This function formats a symbol in the selection to a bulleted list.
// If the selection is not collapsed, it returns false.
// If the selection is collapsed and the text is not the symbol, it returns false.
// If the selection is collapsed and the text is the symbol, it will format the current node to a bulleted list.
Future<bool> _formatSymbolToBulletedList(
  EditorState editorState,
  String symbol,
) async {
  assert(symbol.length == 1);

  return formatMarkdownSymbol(
    editorState,
    (node) => node.type != 'bulleted_list',
    (text, _) => text == symbol,
    (_, node, delta) => Node(
      type: 'bulleted_list',
      attributes: {
        'delta': delta.compose(Delta()..delete(symbol.length)).toJson(),
      },
    ),
  );
}
