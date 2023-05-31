import 'package:appflowy_editor/appflowy_editor.dart';

const _doubleQuote = '"';

/// Convert '" ' to quote
///
/// - support
///   - desktop
///   - mobile
///   - web
///
CharacterShortcutEvent formatDoubleQuoteToQuote = CharacterShortcutEvent(
  key: 'format greater to quote',
  character: ' ',
  handler: (editorState) async => await formatMarkdownSymbol(
    editorState,
    (node) => node.type != QuoteBlockKeys.type,
    (text, _) => text == _doubleQuote,
    (_, node, delta) => Node(
      type: 'quote',
      attributes: {
        'delta': delta.compose(Delta()..delete(_doubleQuote.length)).toJson(),
      },
    ),
  ),
);
