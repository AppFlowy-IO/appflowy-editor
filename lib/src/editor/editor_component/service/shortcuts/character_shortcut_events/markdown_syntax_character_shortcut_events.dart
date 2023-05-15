import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/shortcuts/character_shortcut_events/format_by_wrapping_with_double_character/format_bold.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/shortcuts/character_shortcut_events/format_by_wrapping_with_double_character/format_strikethrough.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/shortcuts/character_shortcut_events/format_by_wrapping_with_single_character/format_code.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/shortcuts/character_shortcut_events/format_by_wrapping_with_single_character/format_italic.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/shortcuts/character_shortcut_events/format_by_wrapping_with_single_character/format_strikethrough.dart';

// Include all the shortcut(formatting) events triggered by wrapping text with  double characters.
// 1. double asterisk to bold -> **abc**
// 2. double underscore to bold -> __abc__

// Include all the shortcut(formatting) events triggered by wrapping text with a single character.
// 1. backquote to code -> `abc`
// 2. underscore to italic -> _abc_
// 3. asterisk to italic -> *abc*
// 4. tilde to strikethrough -> ~abc~

final List<CharacterShortcutEvent> markdownSyntaxShortcutEvents = [
  // format code, `code`
  formatBackquoteToCode,

  // format italic,
  // _italic_
  // *italic*
  formatUnderscoreToItalic,
  formatAsteriskToItalic,

  // format strikethrough,
  // ~strikethrough~
  // ~~strikethrough~~
  formatTildeToStrikethrough,
  formatDoubleTilesToStrikethrough,

  // format bold, **bold** or __bold__
  formatDoubleAsterisksToBold,
  formatDoubleUnderscoresToBold,
];
