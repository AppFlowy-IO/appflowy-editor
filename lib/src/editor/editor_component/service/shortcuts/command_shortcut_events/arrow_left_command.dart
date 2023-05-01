import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final List<CommandShortcutEvent> arrowLeftKeys = [
  moveCursorLeftCommand,
  moveCursorToBeginCommand,
  moveCursorToLeftWordCommand,
];

/// Arrow left key events.
///
/// - support
///   - desktop
///   - web
///

// arrow left key
// move the cursor forward one character
CommandShortcutEvent moveCursorLeftCommand = CommandShortcutEvent(
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

// arrow left key + ctrl or command
// move the cursor to the beginning of the block
CommandShortcutEvent moveCursorToBeginCommand = CommandShortcutEvent(
  key: 'move the cursor forward one character',
  command: 'ctrl+arrow left',
  macOSCommand: 'cmd+arrow left',
  handler: _moveCursorToBeginCommandHandler,
);

CommandShortcutEventHandler _moveCursorToBeginCommandHandler = (editorState) {
  if (PlatformExtension.isMobile) {
    assert(false, 'arrow left key is not supported on mobile platform.');
    return KeyEventResult.ignored;
  }
  editorState.moveCursorForward(SelectionMoveRange.line);
  return KeyEventResult.handled;
};

// arrow left key + alt
// move the cursor to the left word
CommandShortcutEvent moveCursorToLeftWordCommand = CommandShortcutEvent(
  key: 'move the cursor to the left word',
  command: 'alt+arrow left',
  handler: _moveCursorToLeftWordCommandHandler,
);

CommandShortcutEventHandler _moveCursorToLeftWordCommandHandler =
    (editorState) {
  final selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }
  editorState.moveCursorForward(SelectionMoveRange.word);
  return KeyEventResult.handled;
};
