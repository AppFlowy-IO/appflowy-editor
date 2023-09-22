import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// Select all key event.
///
/// - support
///   - desktop
///   - web
///
final CommandShortcutEvent selectAllCommand = CommandShortcutEvent(
  key: 'select all the selectable content',
  command: 'ctrl+a',
  macOSCommand: 'cmd+a',
  handler: _selectAllCommandHandler,
);

CommandShortcutEventHandler _selectAllCommandHandler = (editorState) {
  if (editorState.document.root.children.isEmpty) {
    return KeyEventResult.handled;
  }
  final firstSelectable = editorState.getFirstSelectable();
  final lastSelectable = editorState.getLastSelectable();
  if (firstSelectable == null || lastSelectable == null) {
    return KeyEventResult.handled;
  }
  final start = firstSelectable.$2.start(firstSelectable.$1);
  final end = lastSelectable.$2.end(lastSelectable.$1);
  editorState.updateSelectionWithReason(
    Selection(start: start, end: end),
    reason: SelectionUpdateReason.selectAll,
  );
  return KeyEventResult.handled;
};
