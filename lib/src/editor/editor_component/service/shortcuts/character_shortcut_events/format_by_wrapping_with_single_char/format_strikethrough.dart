import 'package:appflowy_editor/appflowy_editor.dart';

const String _tilde = '~';

/// format the text surrounded by single tilde to strikethrough
///
/// - support
///   - desktop
///   - mobile
///   - web
///
final CharacterShortcutEvent formatTildeToStrikethrough =
    CharacterShortcutEvent(
  key: 'format the text surrounded by single tilde to strikethrough',
  character: _tilde,
  handler: (editorState) async =>
      await handleFormatByWrappingWithSingleCharacter(
    editorState: editorState,
    character: _tilde,
    formatStyle: FormatStyleByWrappingWithSingleChar.strikethrough,
  ),
);
