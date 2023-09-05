import 'package:appflowy_editor/appflowy_editor.dart';
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
// move the cursor downward vertically
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
/// move the cursor to the bottommost position of the document and select everything in between
CommandShortcutEvent moveCursorBottomSelectCommand = CommandShortcutEvent(
  key: 'move cursor to end of file and select all',
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
  final nodes = editorState.document.root.children;
  Position? result;
  for (var i = nodes.length - 1; i >= 0; i--) {
    final selectable =
        editorState.renderer.blockComponentSelectable(nodes[i].type);
    if (selectable != null) {
      result = selectable.end(nodes[i]);
      break;
    }
  }

  if (result == null) {
    return KeyEventResult.ignored;
  }

  editorState.scrollService?.jumpTo(result.path.first);
  editorState.updateSelectionWithReason(
    selection.copyWith(end: result),
    reason: SelectionUpdateReason.uiEvent,
  );

  return KeyEventResult.handled;
};

/// arrow down + ctrl or cmd
/// move the cursor to the bottommost position of the document
CommandShortcutEvent moveCursorBottomCommand = CommandShortcutEvent(
  key: 'move cursor to end of file',
  command: 'ctrl+arrow down',
  macOSCommand: 'cmd+arrow down',
  handler: _moveCursorBottomCommandHandler,
);

CommandShortcutEventHandler _moveCursorBottomCommandHandler = (editorState) {
  final selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }
  final nodes = editorState.document.root.children;
  Position? result;
  for (var i = nodes.length - 1; i >= 0; i--) {
    final selectable =
        editorState.renderer.blockComponentSelectable(nodes[i].type);
    if (selectable != null) {
      result = selectable.end(nodes[i]);
      break;
    }
  }

  if (result == null) {
    return KeyEventResult.ignored;
  }

  editorState.scrollService?.jumpTo(result.path.first);
  editorState.updateSelectionWithReason(
    Selection.collapsed(result),
    reason: SelectionUpdateReason.uiEvent,
  );

  return KeyEventResult.handled;
};

/// arrow down + shift
/// moves vertically down one line and selects everything between
CommandShortcutEvent moveCursorDownSelectCommand = CommandShortcutEvent(
  key: 'move cursor down and select one line',
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
