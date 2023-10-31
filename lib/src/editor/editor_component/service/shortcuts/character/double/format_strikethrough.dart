import 'package:appflowy_editor/src/editor/editor_component/service/shortcuts/character_shortcut_event.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/shortcuts/character/double/format_double_characters.dart';

const _tile = '~';

/// format the text surrounded by double asterisks to bold
///
/// - support
///   - desktop
///   - mobile
///   - web
///
final CharacterShortcutEvent formatDoubleTilesToStrikethrough =
    CharacterShortcutEvent(
  key: 'format the text surrounded by double asterisks to bold',
  character: _tile,
  handler: (editorState) async => handleFormatByWrappingWithDoubleCharacter(
    editorState: editorState,
    character: _tile,
    formatStyle: DoubleCharacterFormatStyle.strikethrough,
  ),
);
