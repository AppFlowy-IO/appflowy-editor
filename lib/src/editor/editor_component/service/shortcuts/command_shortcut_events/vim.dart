import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final List<CommandShortcutEvent> vimKeyModes = [
  insertOnNewLineCommand,
  insertInlineCommand,
  insertNextInlineCommand,
  jumpUpCommand,
  jumpDownCommand,
  jumpLeftCommand,
  jumpRightCommand,
];

/// Insert trigger keys
final CommandShortcutEvent insertOnNewLineCommand = CommandShortcutEvent(
  key: 'insert new line below previous selection',
  command: 'o',
  handler: _insertOnNewLineCommandHandler,
);

CommandShortcutEventHandler _insertOnNewLineCommandHandler = (editorState) {
  final afKeyboard = editorState.service.keyboardServiceKey;

  if (afKeyboard.currentState != null &&
      afKeyboard.currentState is AppFlowyKeyboardService) {
    if (editorState.selection == null || editorState.prevSelection != null) {
      //NOTE: Call editable first before changing mode
      editorState.editable = true;
      editorState.mode = VimModes.insertMode;
      editorState.selection = editorState.selection;
      editorState.insertNewLine();
      editorState.selectionService.updateSelection(editorState.selection);
      editorState.prevSelection = null;
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }
  return KeyEventResult.ignored;
};

final CommandShortcutEvent insertInlineCommand = CommandShortcutEvent(
  key: 'enter insert mode from previous selection',
  command: 'i',
  handler: _insertInlineCommandHandler,
);

CommandShortcutEventHandler _insertInlineCommandHandler = (editorState) {
  final afKeyboard = editorState.service.keyboardServiceKey;
  if (afKeyboard.currentState != null &&
      afKeyboard.currentState is AppFlowyKeyboardService) {
    if (editorState.selection == null || editorState.prevSelection != null) {
      //NOTE: Call editable first before changing mode
      editorState.editable = true;
      editorState.mode = VimModes.insertMode;
      editorState.selection = editorState.selection;
      editorState.selectionService.updateSelection(editorState.selection);
      editorState.prevSelection = null;
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }
  return KeyEventResult.ignored;
};

final CommandShortcutEvent insertNextInlineCommand = CommandShortcutEvent(
  key: 'enter insert mode on next character',
  command: 'a',
  handler: _insertNextInlineCommandHandler,
);

CommandShortcutEventHandler _insertNextInlineCommandHandler = (editorState) {
  final afKeyboard = editorState.service.keyboardServiceKey;
  if (afKeyboard.currentState != null &&
      afKeyboard.currentState is AppFlowyKeyboardService) {
    if (editorState.selection == null || editorState.prevSelection != null) {
      //NOTE: Call editable first before changing mode
      editorState.editable = true;
      editorState.mode = VimModes.insertMode;
      editorState.selection = editorState.selection;
      editorState.moveCursor(SelectionMoveDirection.backward);
      editorState.selectionService.updateSelection(editorState.selection);
      editorState.prevSelection = null;
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }
  return KeyEventResult.ignored;
};

/// Motion Keys
final CommandShortcutEvent jumpDownCommand = CommandShortcutEvent(
  key: 'move the cursor downward in normal mode',
  command: 'j',
  handler: _jumpDownCommandHandler,
);

CommandShortcutEventHandler _jumpDownCommandHandler = (editorState) {
  final afKeyboard = editorState.service.keyboardServiceKey;
  if (afKeyboard.currentState != null &&
      afKeyboard.currentState is AppFlowyKeyboardService) {
    if (editorState.selection != null &&
        editorState.mode == VimModes.normalMode) {
      final selection = editorState.selection;
      final downPosition =
          selection?.end.moveVertical(editorState, upwards: false);
      editorState.updateSelectionWithReason(
          downPosition == null ? null : Selection.collapsed(downPosition),
          reason: SelectionUpdateReason.uiEvent);
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }
  return KeyEventResult.ignored;
};

final CommandShortcutEvent jumpUpCommand = CommandShortcutEvent(
  key: 'move the cursor upward in normal mode',
  command: 'k',
  handler: _jumpUpCommandHandler,
);

CommandShortcutEventHandler _jumpUpCommandHandler = (editorState) {
  final afKeyboard = editorState.service.keyboardServiceKey;
  if (afKeyboard.currentState != null &&
      afKeyboard.currentState is AppFlowyKeyboardService) {
    // editorState.scrollService!.goBallistic(4);
    if (editorState.selection != null &&
        editorState.mode == VimModes.normalMode) {
      final selection = editorState.selection;
      final downPosition =
          selection?.end.moveVertical(editorState, upwards: true);
      editorState.updateSelectionWithReason(
        downPosition == null ? null : Selection.collapsed(downPosition),
        reason: SelectionUpdateReason.uiEvent,
      );
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }
  return KeyEventResult.ignored;
};

final CommandShortcutEvent jumpLeftCommand = CommandShortcutEvent(
  key: 'move the cursor to the left',
  command: 'h',
  handler: _jumpLeftCommandHandler,
);

CommandShortcutEventHandler _jumpLeftCommandHandler = (editorState) {
  final afKeyboard = editorState.service.keyboardServiceKey;
  if (afKeyboard.currentState != null &&
      afKeyboard.currentState is AppFlowyKeyboardService) {
    if (editorState.selection != null &&
        editorState.mode == VimModes.normalMode) {
      final selection = editorState.selection;
      final downPosition =
          selection?.end.moveHorizontal(editorState, forward: true);
      editorState.updateSelectionWithReason(
        downPosition == null ? null : Selection.collapsed(downPosition),
        reason: SelectionUpdateReason.uiEvent,
      );
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }
  return KeyEventResult.ignored;
};

final CommandShortcutEvent jumpRightCommand = CommandShortcutEvent(
  key: 'move the cursor downward',
  command: 'l',
  handler: _jumpRightCommandHandler,
);

CommandShortcutEventHandler _jumpRightCommandHandler = (editorState) {
  final afKeyboard = editorState.service.keyboardServiceKey;
  if (afKeyboard.currentState != null &&
      afKeyboard.currentState is AppFlowyKeyboardService) {
    if (editorState.selection != null &&
        editorState.mode == VimModes.normalMode) {
      final selection = editorState.selection;
      final downPosition =
          selection?.end.moveHorizontal(editorState, forward: false);
      editorState.updateSelectionWithReason(
        downPosition == null ? null : Selection.collapsed(downPosition),
        reason: SelectionUpdateReason.uiEvent,
      );
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }
  return KeyEventResult.ignored;
};
