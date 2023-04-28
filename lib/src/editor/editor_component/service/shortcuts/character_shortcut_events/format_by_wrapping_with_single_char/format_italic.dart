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
  handler: (editorState) async {
    return handleFormatByWrappingWithSingleChar(
      editorState: editorState,
      char: _underscore,
      formatStyle: FormatStyleByWrappingWithSingleChar.italic,
    );
  },
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
  handler: (editorState) async {
    return handleFormatByWrappingWithSingleChar(
      editorState: editorState,
      char: _asterisk,
      formatStyle: FormatStyleByWrappingWithSingleChar.italic,
    );
  },
);
