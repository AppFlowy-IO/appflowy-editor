import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final List<CommandShortcutEvent> vimKeyModes = [
  insertOnNewLineCommand,
  insertInlineCommand,
  insertNextInlineCommand,
  jumpDownCommand,
];
/*
final CommandShortcutEvent moveMentCommand = CommandShortcutEvent(
  key: 'move down with j',
  command: 'j',
  handler: _moveMentCommand,
);

CommandShortcutEventHandler _moveMentCommand = (editorState) {
  final keyboardServiceKey = editorState.service.keyboardServiceKey;
  final selection = editorState.selection;
  print('Passed through event handler');
  /*
  if (selection == null) {
    return KeyEventResult.ignored;
  }
  */
  if (keyboardServiceKey.currentState != null &&
      keyboardServiceKey.currentState is AppFlowyKeyboardService) {
    // editorState.service.keyboardService?.enableKeyBoard(selection!);
    // final downPos = selection?.end.moveVertical(editorState, upwards: false);
    if (selection == null) {
      //NOTE: This works fine
      // editorState.scrollService?.jumpToBottom();
      // final s = editorState.service.selectionService.currentSelection.value;
      //editorState.service.keyboardService?.enableKeyBoard(s!);

      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
    /*
    editorState.updateSelectionWithReason(
      downPos == null ? null : Selection.collapsed(downPos),
      reason: SelectionUpdateReason.uiEvent,
    );
    */
  }
  // editorState.scrollService?.disable();
  return KeyEventResult.ignored;
};
*/

final CommandShortcutEvent insertOnNewLineCommand = CommandShortcutEvent(
  key: 'insert new line below previous selection',
  command: 'o',
  handler: _insertOnNewLineCommandHandler,
);

CommandShortcutEventHandler _insertOnNewLineCommandHandler = (editorState) {
  final afKeyboard = editorState.service.keyboardServiceKey;

  if (afKeyboard.currentState != null &&
      afKeyboard.currentState is AppFlowyKeyboardService) {
    if (editorState.selection == null) {
      editorState.selection = editorState.prevSelection;
      editorState.insertNewLine();
      editorState.selectionService.updateSelection(editorState.selection);
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }
  return KeyEventResult.ignored;
};

final CommandShortcutEvent jumpDownCommand = CommandShortcutEvent(
  key: 'move the cursor downward',
  command: 'j',
  handler: _jumpDownCommandHandler,
);

CommandShortcutEventHandler _jumpDownCommandHandler = (editorState) {
  final afKeyboard = editorState.service.keyboardServiceKey;
  if (afKeyboard.currentState != null &&
      afKeyboard.currentState is AppFlowyKeyboardService) {
    // editorState.scrollService!.goBallistic(4);
    if (editorState.selection == null) {
      int scroll = 4;
      //TODO: Figure out a way to jump line by line
      editorState.scrollService?.jumpTo(scroll++);
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
    if (editorState.selection == null) {
      editorState.selection = editorState.prevSelection;
      editorState.selectionService.updateSelection(editorState.selection);
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
    if (editorState.selection == null) {
      editorState.selection = editorState.prevSelection;
      editorState.moveCursor(SelectionMoveDirection.backward);
      editorState.selectionService.updateSelection(editorState.selection);
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }
  return KeyEventResult.ignored;
};
