import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// End key event.
///
/// - support
///   - desktop
///   - web
///
//TODO: Allow custom escape key
final CommandShortcutEvent exitEditingCommand = CommandShortcutEvent(
  key: 'exit the editing mode',
  command: 'escape',
  handler: _exitEditingCommandHandler,
);

CommandShortcutEventHandler _exitEditingCommandHandler = (editorState) {
  if (editorState.mode == VimModes.insertMode &&
      editorState.editable == true &&
      editorState.vimMode == true) {
    editorState.prevSelection = editorState.selection;
    editorState.selection = null;
    editorState.mode = VimModes.normalMode;
    editorState.editable = false;
    editorState.selection = editorState.prevSelection;
    editorState.service.keyboardService?.closeKeyboard();
    return KeyEventResult.handled;
  }
  editorState.selection = null;
  editorState.mode = VimModes.normalMode;
  editorState.service.keyboardService?.closeKeyboard();
  return KeyEventResult.handled;
};
