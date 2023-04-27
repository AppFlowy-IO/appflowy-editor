import 'package:appflowy_editor/appflowy_editor.dart';

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
  handler: handleSingleCharacterFormat(
    char: _underscore,
    formatStyle: SingleCharacterFormatStyle.italic,
  ),
);

/// format the text surrounded by single sterisk to italic
///
/// - support
///   - desktop
///   - mobile
///   - web
///
CharacterShortcutEvent formatAsteriskToItalic = CharacterShortcutEvent(
  key: 'format the text surrounded by single asterisk to italic',
  character: _asterisk,
  handler: handleSingleCharacterFormat(
    char: _asterisk,
    formatStyle: SingleCharacterFormatStyle.italic,
  ),
);
