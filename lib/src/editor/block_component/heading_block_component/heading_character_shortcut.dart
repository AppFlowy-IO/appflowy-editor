import 'package:appflowy_editor/appflowy_editor.dart';

/// Convert '# ' to bulleted list
///
/// - support
///   - desktop
///   - mobile
///   - web
///
CharacterShortcutEvent formatSignToHeading = CharacterShortcutEvent(
  key: 'format sign to heading list',
  character: ' ',
  handler: (editorState) async => await formatMarkdownSymbol(
    editorState,
    (node) => true,
    (text, selection) {
      final characters = text.split('');
      // only supports heading1 to heading6 levels
      return characters.every((element) => element == '#') &&
          characters.length < 7;
    },
    (text, node, delta) {
      final numberOfSign = text.split('').length;
      return Node(
        type: 'heading',
        attributes: {
          'delta': delta.compose(Delta()..delete(numberOfSign)).toJson(),
          'level': numberOfSign,
        },
      );
    },
  ),
);
