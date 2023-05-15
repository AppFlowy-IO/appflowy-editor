import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final List<CommandShortcutEvent> arrowLeftKeys = [
  moveCursorLeftCommand,
  moveCursorToBeginCommand,
  moveCursorToLeftWordCommand,
  moveCursorLeftSelectCommand,
  moveCursorBeginSelectCommand,
  moveCursorLeftWordSelectCommand,
];

/// Arrow left key events.
///
/// - support
///   - desktop
///   - web
///

// arrow left key
// move the cursor forward one character
final CommandShortcutEvent moveCursorLeftCommand = CommandShortcutEvent(
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
final CommandShortcutEvent moveCursorToBeginCommand = CommandShortcutEvent(
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
final CommandShortcutEvent moveCursorToLeftWordCommand = CommandShortcutEvent(
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

// arrow left key + alt + shift
final CommandShortcutEvent moveCursorLeftWordSelectCommand =
    CommandShortcutEvent(
  key: 'move the cursor to select the left word',
  command: 'alt+shift+arrow left',
  handler: _moveCursorLeftWordSelectCommandHandler,
);

CommandShortcutEventHandler _moveCursorLeftWordSelectCommandHandler =
    (editorState) {
  final selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }
  final end = selection.end.moveHorizontal(
    editorState,
    selectionRange: SelectionRange.word,
  );
  if (end == null) {
    return KeyEventResult.ignored;
  }
  editorState.updateSelectionWithReason(
    selection.copyWith(end: end),
    reason: SelectionUpdateReason.uiEvent,
  );
  return KeyEventResult.handled;
};

// arrow left key + shift
//
final CommandShortcutEvent moveCursorLeftSelectCommand = CommandShortcutEvent(
  key: 'move the cursor left select',
  command: 'shift+arrow left',
  handler: _moveCursorLeftSelectCommandHandler,
);

CommandShortcutEventHandler _moveCursorLeftSelectCommandHandler =
    (editorState) {
  final selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }
  final end = selection.end.moveHorizontal(editorState);
  if (end == null) {
    return KeyEventResult.ignored;
  }
  editorState.updateSelectionWithReason(
    selection.copyWith(end: end),
    reason: SelectionUpdateReason.uiEvent,
  );
  return KeyEventResult.handled;
};

// arrow left key + shift + ctrl or cmd
final CommandShortcutEvent moveCursorBeginSelectCommand = CommandShortcutEvent(
  key: 'move the cursor left select',
  command: 'ctrl+shift+arrow left',
  macOSCommand: 'cmd+shift+arrow left',
  handler: _moveCursorBeginSelectCommandHandler,
);

CommandShortcutEventHandler _moveCursorBeginSelectCommandHandler =
    (editorState) {
  final selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }
  final nodes = editorState.getNodesInSelection(selection);
  if (nodes.isEmpty) {
    return KeyEventResult.ignored;
  }
  var end = selection.end;
  final position = nodes.last.selectable?.start();
  if (position != null) {
    end = position;
  }
  editorState.updateSelectionWithReason(
    selection.copyWith(end: end),
    reason: SelectionUpdateReason.uiEvent,
  );
  return KeyEventResult.handled;
};
