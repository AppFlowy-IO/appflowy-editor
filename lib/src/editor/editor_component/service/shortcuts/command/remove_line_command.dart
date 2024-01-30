import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// Remove Line to the Left.
///
/// - support
///   - desktop
///   - web
///   - mobile
///

final CommandShortcutEvent deleteLeftSentenceCommand = CommandShortcutEvent(
  key: 'delete the left line',
  getDescription: () => AppFlowyEditorL10n.current.cmdDeleteLineLeft,
  command: 'ctrl+alt+backspace',
  macOSCommand: 'cmd+backspace',
  handler: _deleteLeftSentenceCommandHandler,
);

CommandShortcutEventHandler _deleteLeftSentenceCommandHandler = (editorState) {
  final selection = editorState.selection;
  if (selection == null || !selection.isCollapsed) {
    return KeyEventResult.ignored;
  }

  final node = editorState.getNodeAtPath(selection.end.path);
  final delta = node?.delta;
  if (node == null || delta == null) {
    return KeyEventResult.ignored;
  }

  final transaction = editorState.transaction;
  transaction.deleteText(
    node,
    0,
    selection.endIndex,
  );
  editorState.apply(transaction);
  return KeyEventResult.handled;
};
