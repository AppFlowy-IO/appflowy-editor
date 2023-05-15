import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/base_component/markdown_format_helper.dart';

const _greater = '>';

/// Convert '> ' to quote
///
/// - support
///   - desktop
///   - mobile
///   - web
///
CharacterShortcutEvent formatGreaterToQuote = CharacterShortcutEvent(
  key: 'format greater to quote',
  character: ' ',
  handler: (editorState) async => await formatMarkdownSymbol(
    editorState,
    (node) => node.type != 'bulleted_list',
    (text, _) => text == _greater,
    (_, node, delta) => Node(
      type: 'quote',
      attributes: {
        'delta': delta.compose(Delta()..delete(_greater.length)).toJson(),
      },
    ),
  ),
);
