import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final List<CommandShortcutEvent> arrowDownKeys = [
  moveCursorDownCommand,
];

/// Arrow down key events.
///
/// - support
///   - desktop
///   - web
///

// arrow down key
// move the cursor backward one character
CommandShortcutEvent moveCursorDownCommand = CommandShortcutEvent(
  key: 'move the cursor downward',
  command: 'arrow down',
  handler: _moveCursorDownCommandHandler,
);

CommandShortcutEventHandler _moveCursorDownCommandHandler = (editorState) {
  if (PlatformExtension.isMobile) {
    assert(false, 'arrow down key is not supported on mobile platform.');
    return KeyEventResult.ignored;
  }

  final selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }

  final downPosition = selection.end.moveVertical(editorState, upwards: false);
  editorState.updateSelectionWithReason(
    downPosition == null ? null : Selection.collapsed(downPosition),
    reason: SelectionUpdateReason.uiEvent,
  );

  return KeyEventResult.handled;
};
