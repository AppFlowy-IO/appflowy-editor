import 'package:appflowy_editor/src/editor/editor_component/service/shortcuts/character_shortcut_event.dart';
import 'format_single_character.dart';

const _underscore = '_';
const _asterisk = '*';

/// format the text surrounded by single underscore to italic
///
/// - support
///   - desktop
///   - mobile
///   - web
///
CharacterShortcutEvent formatUnderscoreToItalic = CharacterShortcutEvent(
  key: 'format the text surrounded by single underscore to italic',
  character: _underscore,
  handler: (editorState) async => handleFormatByWrappingWithSingleCharacter(
    editorState: editorState,
    character: _underscore,
    formatStyle: FormatStyleByWrappingWithSingleChar.italic,
  ),
);

/// format the text surrounded by single asterisk to italic
///
/// - support
///   - desktop
///   - mobile
///   - web
///
final CharacterShortcutEvent formatAsteriskToItalic = CharacterShortcutEvent(
  key: 'format the text surrounded by single asterisk to italic',
  character: _asterisk,
  handler: (editorState) async => handleFormatByWrappingWithSingleCharacter(
    editorState: editorState,
    character: _asterisk,
    formatStyle: FormatStyleByWrappingWithSingleChar.italic,
  ),
);
