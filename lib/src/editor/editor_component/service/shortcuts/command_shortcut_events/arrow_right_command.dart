import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final List<CommandShortcutEvent> arrowRightKeys = [
  moveCursorRightCommand,
  moveCursorToEndCommand,
  moveCursorToRightWordCommand,
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

// arrow right key + alt
// move the cursor to the right word
CommandShortcutEvent moveCursorToRightWordCommand = CommandShortcutEvent(
  key: 'move the cursor to the right word',
  command: 'alt+arrow right',
  handler: _moveCursorToRightWordCommandHandler,
);

CommandShortcutEventHandler _moveCursorToRightWordCommandHandler =
    (editorState) {
  final selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }
  editorState.moveCursorBackward(SelectionMoveRange.word);
  return KeyEventResult.handled;
};
