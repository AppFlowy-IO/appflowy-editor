import 'package:appflowy_editor/appflowy_editor.dart';

const _backquote = '`';

/// format the text surrounded by single backquote to code
///
/// - support
///   - desktop
///   - mobile
///   - web
///
CharacterShortcutEvent formatBackquoteToCode = CharacterShortcutEvent(
  key: 'format the text surrounded by single backquote to code',
  character: _backquote,
  handler: handleSingleCharacterFormat(
    char: _backquote,
    formatStyle: SingleCharacterFormatStyle.code,
  ),
);
