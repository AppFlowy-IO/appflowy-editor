import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

final List<CommandShortcutEvent> arrowDownKeys = [
  moveCursorDownCommand,
  moveCursorBottomSelectCommand,
  moveCursorBottomCommand,
  moveCursorDownSelectCommand,
];

/// Arrow down key events.
///
/// - support
///   - desktop
///   - web
///

// arrow down key
// move the cursor backward one character
final CommandShortcutEvent moveCursorDownCommand = CommandShortcutEvent(
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

/// arrow down + shift + ctrl or cmd
/// cursor bottom select
CommandShortcutEvent moveCursorBottomSelectCommand = CommandShortcutEvent(
  key: 'cursor bottom select', // TODO: rename it.
  command: 'ctrl+shift+arrow down',
  macOSCommand: 'cmd+shift+arrow down',
  handler: _moveCursorBottomSelectCommandHandler,
);

CommandShortcutEventHandler _moveCursorBottomSelectCommandHandler =
    (editorState) {
  final selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }
  final selectable = editorState.document.root.children
      .lastWhereOrNull((element) => element.selectable != null)
      ?.selectable;
  if (selectable == null) {
    return KeyEventResult.ignored;
  }
  final end = selectable.end();
  editorState.updateSelectionWithReason(
    selection.copyWith(end: end),
    reason: SelectionUpdateReason.uiEvent,
  );
  return KeyEventResult.handled;
};

/// arrow down + ctrl or cmd
/// move the cursor to the bottommost position of the document and select it
CommandShortcutEvent moveCursorBottomCommand = CommandShortcutEvent(
  key: 'move cursor bottom', // TODO: rename it.
  command: 'ctrl+arrow down',
  macOSCommand: 'cmd+arrow down',
  handler: _moveCursorBottomCommandHandler,
);

CommandShortcutEventHandler _moveCursorBottomCommandHandler = (editorState) {
  final selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }
  final selectable = editorState.document.root.children
      .lastWhereOrNull((element) => element.selectable != null)
      ?.selectable;
  if (selectable == null) {
    return KeyEventResult.ignored;
  }
  final position = selectable.end();
  editorState.updateSelectionWithReason(
    Selection.collapsed(position),
    reason: SelectionUpdateReason.uiEvent,
  );
  return KeyEventResult.handled;
};

/// arrow up + ctrl or cmd
CommandShortcutEvent moveCursorDownSelectCommand = CommandShortcutEvent(
  key: 'move cursor down select', // TODO: rename it.
  command: 'shift+arrow down',
  macOSCommand: 'shift+arrow down',
  handler: _moveCursorDownSelectCommandHandler,
);

CommandShortcutEventHandler _moveCursorDownSelectCommandHandler =
    (editorState) {
  final selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }
  final end = selection.end.moveVertical(editorState, upwards: false);
  if (end == null) {
    return KeyEventResult.ignored;
  }
  editorState.updateSelectionWithReason(
    selection.copyWith(end: end),
    reason: SelectionUpdateReason.uiEvent,
  );
  return KeyEventResult.handled;
};
