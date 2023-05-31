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
  command: 'ctrl+z',
  macOSCommand: 'cmd+z',
  handler: _undoCommandHandler,
);

CommandShortcutEventHandler _undoCommandHandler = (editorState) {
  if (PlatformExtension.isMobile) {
    assert(false, 'undoCommand is not supported on mobile platform.');
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
  key: 'undo',
  command: 'ctrl+shift+z',
  macOSCommand: 'cmd+shift+z',
  handler: _redoCommandHandler,
);

CommandShortcutEventHandler _redoCommandHandler = (editorState) {
  if (PlatformExtension.isMobile) {
    assert(false, 'redoCommand is not supported on mobile platform.');
    return KeyEventResult.ignored;
  }
  editorState.undoManager.redo();
  return KeyEventResult.handled;
};
