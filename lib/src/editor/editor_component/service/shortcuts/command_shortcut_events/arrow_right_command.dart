import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// Arrow right key event.
///
/// - support
///   - desktop
///   - web
///
CommandShortcutEvent arrowRightCommand = CommandShortcutEvent(
  key: 'move the cursor backward one character',
  command: 'arrow right',
  handler: _arrowRightCommandHandler,
);

CommandShortcutEventHandler _arrowRightCommandHandler = (editorState) {
  if (PlatformExtension.isMobile) {
    assert(false, 'arrow right key is not supported on mobile platform.');
    return KeyEventResult.ignored;
  }
  editorState.moveCursorBackward(SelectionMoveRange.character);
  return KeyEventResult.handled;
};
