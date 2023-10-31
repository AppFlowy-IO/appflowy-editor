import 'package:appflowy_editor/src/editor/editor_component/service/shortcuts/character_shortcut_event.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/shortcuts/character/double/format_double_characters.dart';

const _asterisk = '*';
const _underscore = '_';

/// format the text surrounded by double asterisks to bold
///
/// - support
///   - desktop
///   - mobile
///   - web
///
final CharacterShortcutEvent formatDoubleAsterisksToBold =
    CharacterShortcutEvent(
  key: 'format the text surrounded by double asterisks to bold',
  character: _asterisk,
  handler: (editorState) async => handleFormatByWrappingWithDoubleCharacter(
    editorState: editorState,
    character: _asterisk,
    formatStyle: DoubleCharacterFormatStyle.bold,
  ),
);

/// format the text surrounded by double underscores to bold
///
/// - support
///   - desktop
///   - mobile
///   - web
///
final CharacterShortcutEvent formatDoubleUnderscoresToBold =
    CharacterShortcutEvent(
  key: 'format the text surrounded by double underscores to bold',
  character: _underscore,
  handler: (editorState) async => handleFormatByWrappingWithDoubleCharacter(
    editorState: editorState,
    character: _underscore,
    formatStyle: DoubleCharacterFormatStyle.bold,
  ),
);
