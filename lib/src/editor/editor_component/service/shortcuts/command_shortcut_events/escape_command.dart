import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// End key event.
///
/// - support
///   - desktop
///   - web
///
final CommandShortcutEvent exitEditingCommand = CommandShortcutEvent(
  key: 'exit the editing mode',
  command: 'escape',
  handler: _exitEditingCommandHandler,
);

CommandShortcutEventHandler _exitEditingCommandHandler = (editorState) {
  editorState.selection = null;
  editorState.service.keyboardService?.closeKeyboard();
  return KeyEventResult.handled;
};
