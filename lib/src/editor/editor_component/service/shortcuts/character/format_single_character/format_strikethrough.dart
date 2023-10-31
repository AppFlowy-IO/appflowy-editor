import 'package:appflowy_editor/src/editor/editor_component/service/shortcuts/character_shortcut_event.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/shortcuts/character/format_single_character/format_single_character.dart';

const String _tilde = '~';

/// format the text surrounded by single tilde to strikethrough
///
/// - support
///   - desktop
///   - mobile
///   - web
///

CharacterShortcutEvent formatTildeToStrikethrough = CharacterShortcutEvent(
  key: 'format the text surrounded by single tilde to strikethrough',
  character: _tilde,
  handler: (editorState) async => handleFormatByWrappingWithSingleCharacter(
    editorState: editorState,
    character: _tilde,
    formatStyle: FormatStyleByWrappingWithSingleChar.strikethrough,
  ),
);
