import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final List<CommandShortcutEvent> arrowUpKeys = [
  moveCursorUpCommand,
];

/// Arrow up key events.
///
/// - support
///   - desktop
///   - web
///

// arrow up key
// move the cursor backward one character
CommandShortcutEvent moveCursorUpCommand = CommandShortcutEvent(
  key: 'move the cursor upward',
  command: 'arrow up',
  handler: _moveCursorUpCommandHandler,
);

CommandShortcutEventHandler _moveCursorUpCommandHandler = (editorState) {
  if (PlatformExtension.isMobile) {
    assert(false, 'arrow up key is not supported on mobile platform.');
    return KeyEventResult.ignored;
  }

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
