import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final List<CommandShortcutEvent> arrowRightKeys = [
  moveCursorRightCommand,
  moveCursorToEndCommand,
];

/// Arrow right key events.
///
/// - support
///   - desktop
///   - web
///

// arrow right key
// move the cursor backward one character
CommandShortcutEvent moveCursorRightCommand = CommandShortcutEvent(
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

// arrow right key + ctrl or command
// move the cursor to the end of the block
CommandShortcutEvent moveCursorToEndCommand = CommandShortcutEvent(
  key: 'move the cursor backward one character',
  command: 'ctrl+arrow right',
  macOSCommand: 'cmd+arrow right',
  handler: _moveCursorToEndCommandHandler,
);

CommandShortcutEventHandler _moveCursorToEndCommandHandler = (editorState) {
  if (PlatformExtension.isMobile) {
    assert(false, 'arrow right key is not supported on mobile platform.');
    return KeyEventResult.ignored;
  }
  editorState.moveCursorBackward(SelectionMoveRange.line);
  return KeyEventResult.handled;
};
