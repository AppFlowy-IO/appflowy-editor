import 'package:appflowy_editor/src/editor/editor_component/service/shortcuts/character_shortcut_event.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/shortcuts/character/format_single_character/format_single_character.dart';

const _backquote = '`';

/// format the text surrounded by single backquote to code
///
/// - support
///   - desktop
///   - mobile
///   - web
///
final CharacterShortcutEvent formatBackquoteToCode = CharacterShortcutEvent(
  key: 'format the text surrounded by single backquote to code',
  character: _backquote,
  handler: (editorState) async => handleFormatByWrappingWithSingleCharacter(
    editorState: editorState,
    character: _backquote,
    formatStyle: FormatStyleByWrappingWithSingleChar.code,
  ),
);
