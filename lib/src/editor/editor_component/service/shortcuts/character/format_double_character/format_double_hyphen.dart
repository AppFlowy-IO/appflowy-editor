import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/shortcuts/character_shortcut_events/format_double_characters/utils.dart';

const _hyphen = '-';
const _emDash = '—'; // This is an em dash — not a single dash - !!

/// format two hyphens into an em dash
///
/// - support
///   - desktop
///   - mobile
///   - web
///
final CharacterShortcutEvent formatDoubleHyphenEmDash = CharacterShortcutEvent(
  key: 'format double hyphen into an em dash',
  character: _hyphen,
  handler: (editorState) async => handleDoubleCharacterReplacement(
    editorState: editorState,
    character: _hyphen,
    replacement: _emDash,
  ),
);
