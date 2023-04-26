import 'package:appflowy_editor/appflowy_editor.dart';

const _backtick = '`';

/// format the text surrounded by single backtick to code
///
/// - support
///   - desktop
///   - mobile
///   - web
///
CharacterShortcutEvent formatBacktickToCode = CharacterShortcutEvent(
  key: 'format the text surrounded by single backtick to code',
  character: _backtick,
  handler: handleSingleCharacterFormat(
    char: _backtick,
    formatStyle: SingleCharacterFormatStyle.code,
  ),
);
