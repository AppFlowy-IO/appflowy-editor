import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final List<CommandShortcutEvent> arrowRightKeys = [
  moveCursorRightCommand,
  moveCursorToEndCommand,
  moveCursorToRightWordCommand,
  moveCursorRightSelectCommand,
  moveCursorEndSelectCommand,
  moveCursorRightWordSelectCommand,
];

/// Arrow right key events.
///
/// - support
///   - desktop
///   - web
///

// arrow right key
// move the cursor backward one character
final CommandShortcutEvent moveCursorRightCommand = CommandShortcutEvent(
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
final CommandShortcutEvent moveCursorToEndCommand = CommandShortcutEvent(
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
final CommandShortcutEvent moveCursorToRightWordCommand = CommandShortcutEvent(
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

// arrow right key + alt + shift
final CommandShortcutEvent moveCursorRightWordSelectCommand =
    CommandShortcutEvent(
  key: 'move the cursor to select the right word',
  command: 'alt+shift+arrow right',
  handler: _moveCursorRightWordSelectCommandHandler,
);

CommandShortcutEventHandler _moveCursorRightWordSelectCommandHandler =
    (editorState) {
  final selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }
  final end = selection.end.moveHorizontal(
    editorState,
    selectionRange: SelectionRange.word,
    moveLeft: false,
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

// arrow right key + shift
//
final CommandShortcutEvent moveCursorRightSelectCommand = CommandShortcutEvent(
  key: 'move the cursor right select',
  command: 'shift+arrow right',
  handler: _moveCursorRightSelectCommandHandler,
);

CommandShortcutEventHandler _moveCursorRightSelectCommandHandler =
    (editorState) {
  final selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }
  final end = selection.end.moveHorizontal(editorState, moveLeft: false);
  if (end == null) {
    return KeyEventResult.ignored;
  }
  editorState.updateSelectionWithReason(
    selection.copyWith(end: end),
    reason: SelectionUpdateReason.uiEvent,
  );
  return KeyEventResult.handled;
};

// arrow right key + shift + ctrl or cmd
final CommandShortcutEvent moveCursorEndSelectCommand = CommandShortcutEvent(
  key: 'move the cursor right select',
  command: 'ctrl+shift+arrow right',
  macOSCommand: 'cmd+shift+arrow right',
  handler: _moveCursorEndSelectCommandHandler,
);

CommandShortcutEventHandler _moveCursorEndSelectCommandHandler = (editorState) {
  final selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }
  final nodes = editorState.getNodesInSelection(selection);
  if (nodes.isEmpty) {
    return KeyEventResult.ignored;
  }
  var end = selection.end;
  final position = nodes.last.selectable?.end();
  if (position != null) {
    end = position;
  }
  editorState.updateSelectionWithReason(
    selection.copyWith(end: end),
    reason: SelectionUpdateReason.uiEvent,
  );
  return KeyEventResult.handled;
};
