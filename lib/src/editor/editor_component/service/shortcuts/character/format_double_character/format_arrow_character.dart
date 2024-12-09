import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/shortcuts/character_shortcut_events/format_double_characters/utils.dart';

const _greater = '>';
const _equals = '=';
const _arrow = '⇒';

/// format '=' + '>' into an ⇒
///
/// - support
///   - desktop
///   - mobile
///   - web
///
final CharacterShortcutEvent formatGreaterEqual = CharacterShortcutEvent(
  key: 'format = + > into ⇒',
  character: _greater,
  handler: (editorState) async => handleDoubleCharacterReplacement(
    editorState: editorState,
    character: _greater,
    replacement: _arrow,
    prefixCharacter: _equals,
  ),
);

const _hyphen = '-';
const _singleArrow = '→';

/// format '-' + '>' into an →
///
/// - support
///   - desktop
///   - mobile
///   - web
///
final CharacterShortcutEvent formatGreaterHyphen = CharacterShortcutEvent(
  key: 'format - + > into →',
  character: _greater,
  handler: (editorState) async => handleDoubleCharacterReplacement(
    editorState: editorState,
    character: _greater,
    replacement: _singleArrow,
    prefixCharacter: _hyphen,
  ),
);
