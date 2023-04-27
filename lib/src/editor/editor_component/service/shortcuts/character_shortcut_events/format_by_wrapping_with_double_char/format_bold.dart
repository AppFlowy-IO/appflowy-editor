import 'package:appflowy_editor/appflowy_editor.dart';

const _asterisk = '*';
const _underscore = '_';

/// format the text surrounded by double asterisks to bold
///
/// - support
///   - desktop
///   - mobile
///   - web
///
CharacterShortcutEvent formatDoubleAsterisksToBold = CharacterShortcutEvent(
  key: 'format the text surrounded by double asterisks to bold',
  character: _asterisk,
  handler: (editorState) async {
    return handleFormatByWrappingWithDoubleChar(
      editorState: editorState,
      char: _asterisk,
      formatStyle: DoubleCharacterFormatStyle.bold,
    );
  },
);

/// format the text surrounded by double underscores to bold
///
/// - support
///   - desktop
///   - mobile
///   - web
///
CharacterShortcutEvent formatDoubleUnderscoresToBold = CharacterShortcutEvent(
  key: 'format the text surrounded by double underscores to bold',
  character: _underscore,
  handler: (editorState) async {
    return handleFormatByWrappingWithDoubleChar(
      editorState: editorState,
      char: _underscore,
      formatStyle: DoubleCharacterFormatStyle.bold,
    );
  },
);
