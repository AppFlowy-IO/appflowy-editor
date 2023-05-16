import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// End key event.
///
/// - support
///   - desktop
///   - web
///
final CommandShortcutEvent copyCommand = CommandShortcutEvent(
  key: 'copy the selected content',
  command: 'ctrl+c',
  macOSCommand: 'cmd+c',
  handler: _copyCommandHandler,
);

CommandShortcutEventHandler _copyCommandHandler = (editorState) {
  if (PlatformExtension.isMobile) {
    assert(false, 'copyCommand is not supported on mobile platform.');
    return KeyEventResult.ignored;
  }

  var selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }

  if (!selection.isCollapsed) {
    editorState.deleteSelection(selection);
  }

  // fetch selection again.
  selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.skipRemainingHandlers;
  }
  assert(selection.isCollapsed);

  return KeyEventResult.handled;
};
