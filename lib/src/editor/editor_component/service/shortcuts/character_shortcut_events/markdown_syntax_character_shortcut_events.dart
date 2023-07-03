import 'package:appflowy_editor/appflowy_editor.dart';

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
