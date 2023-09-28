import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

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
      final s = editorState.service.selectionService.currentSelection.value;
      editorState.service.keyboardService?.enableKeyBoard(s!);

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
