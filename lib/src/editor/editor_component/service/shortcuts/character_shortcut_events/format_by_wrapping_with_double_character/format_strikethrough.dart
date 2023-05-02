import 'package:appflowy_editor/src/editor/editor_component/service/shortcuts/character_shortcut_event.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/shortcuts/character_shortcut_events/format_by_wrapping_with_double_character/handle_format_by_wrapping_with_double_character.dart';

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
