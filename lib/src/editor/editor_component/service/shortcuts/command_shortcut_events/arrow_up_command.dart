import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final List<CommandShortcutEvent> arrowUpKeys = [
  moveCursorUpCommand,
  moveCursorTopSelectCommand,
  moveCursorTopCommand,
  moveCursorUpSelectCommand,
];

/// Arrow up key events.
///
/// - support
///   - desktop
///   - web
///

// arrow up key
// move the cursor upward vertically
final CommandShortcutEvent moveCursorUpCommand = CommandShortcutEvent(
  key: 'move the cursor upward',
  command: 'arrow up',
  handler: _moveCursorUpCommandHandler,
);

CommandShortcutEventHandler _moveCursorUpCommandHandler = (editorState) {
  final selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }

  final upPosition = selection.end.moveVertical(editorState);
  editorState.updateSelectionWithReason(
    upPosition == null ? null : Selection.collapsed(upPosition),
    reason: SelectionUpdateReason.uiEvent,
  );

  return KeyEventResult.handled;
};

/// arrow up + shift + ctrl or cmd
/// move the cursor to the topmost position of the document and select everything in between
final CommandShortcutEvent moveCursorTopSelectCommand = CommandShortcutEvent(
  key: 'move cursor to start of file and select all',
  command: 'ctrl+shift+arrow up',
  macOSCommand: 'cmd+shift+arrow up',
  handler: _moveCursorTopSelectCommandHandler,
);

CommandShortcutEventHandler _moveCursorTopSelectCommandHandler = (editorState) {
  final selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }
  final result = editorState.getFirstSelectable();
  if (result == null) {
    return KeyEventResult.ignored;
  }

  final position = result.$2.start(result.$1);
  editorState.scrollService?.jumpToTop();
  editorState.updateSelectionWithReason(
    selection.copyWith(end: position),
    reason: SelectionUpdateReason.uiEvent,
  );
  return KeyEventResult.handled;
};

/// arrow up + ctrl or cmd
/// move the cursor to the topmost position of the document
final CommandShortcutEvent moveCursorTopCommand = CommandShortcutEvent(
  key: 'move cursor to start of file',
  command: 'ctrl+arrow up',
  macOSCommand: 'cmd+arrow up',
  handler: _moveCursorTopCommandHandler,
);

CommandShortcutEventHandler _moveCursorTopCommandHandler = (editorState) {
  final selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }

  final result = editorState.getFirstSelectable();
  if (result == null) {
    return KeyEventResult.ignored;
  }

  final position = result.$2.start(result.$1);
  editorState.scrollService?.jumpToTop();
  editorState.updateSelectionWithReason(
    Selection.collapsed(position),
    reason: SelectionUpdateReason.uiEvent,
  );

  return KeyEventResult.handled;
};

/// arrow up + ctrl or cmd
/// moves vertically down one line and selects everything between
final CommandShortcutEvent moveCursorUpSelectCommand = CommandShortcutEvent(
  key: 'move cursor up and select one line',
  command: 'shift+arrow up',
  macOSCommand: 'shift+arrow up',
  handler: _moveCursorUpSelectCommandHandler,
);

CommandShortcutEventHandler _moveCursorUpSelectCommandHandler = (editorState) {
  final selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }
  final end = selection.end.moveVertical(editorState);
  if (end == null) {
    return KeyEventResult.ignored;
  }
  editorState.updateSelectionWithReason(
    selection.copyWith(end: end),
    reason: SelectionUpdateReason.uiEvent,
  );
  return KeyEventResult.handled;
};
