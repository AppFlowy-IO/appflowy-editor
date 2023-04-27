import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// Arrow left key event.
///
/// - support
///   - desktop
///   - web
///
CommandShortcutEvent arrowLeftCommand = CommandShortcutEvent(
  key: 'move the cursor forward one character',
  command: 'arrow left',
  handler: _arrowLeftCommandHandler,
);

CommandShortcutEventHandler _arrowLeftCommandHandler = (editorState) {
  if (PlatformExtension.isMobile) {
    assert(false, 'arrow left key is not supported on mobile platform.');
    return KeyEventResult.ignored;
  }
  editorState.moveCursorForward(SelectionMoveRange.character);
  return KeyEventResult.handled;
};
// Compare this snippet from lib/src/editor/editor_component/service/shortcuts/command_shortcut_events/arrow_right_command.dart: