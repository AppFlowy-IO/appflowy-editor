import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// Undo key event.
///
/// - support
///   - desktop
///   - web
///
final CommandShortcutEvent undoCommand = CommandShortcutEvent(
  key: 'undo',
  getDescription: () => AppFlowyEditorL10n.current.cmdUndo,
  command: 'ctrl+z',
  macOSCommand: 'cmd+z',
  handler: _undoCommandHandler,
);

CommandShortcutEventHandler _undoCommandHandler = (editorState) {
  if (editorState.selection == null) {
    return KeyEventResult.ignored;
  }
  editorState.undoManager.undo();
  return KeyEventResult.handled;
};

/// Redo key event.
///
/// - support
///   - desktop
///   - web
///
final CommandShortcutEvent redoCommand = CommandShortcutEvent(
  key: 'redo',
  getDescription: () => AppFlowyEditorL10n.current.cmdRedo,
  command: 'ctrl+y,ctrl+shift+z',
  macOSCommand: 'cmd+shift+z',
  handler: _redoCommandHandler,
);

CommandShortcutEventHandler _redoCommandHandler = (editorState) {
  if (editorState.selection == null) {
    return KeyEventResult.ignored;
  }
  editorState.undoManager.redo();
  return KeyEventResult.handled;
};
