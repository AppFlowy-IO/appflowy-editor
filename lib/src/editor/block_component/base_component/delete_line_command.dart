import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// Delete the current line
///
/// - support
///   - desktop
///   - web
///
final CommandShortcutEvent deleteLineCommand = CommandShortcutEvent(
  key: 'delete line',
  getDescription: () => 'Delete the current line',
  command: 'ctrl+x',
  macOSCommand: 'cmd+x',
  handler: _deleteLineCommandHandler,
);

// when the selection is collapsed, press cmd+x(or ctrl+x) should delete the current line
CommandShortcutEventHandler _deleteLineCommandHandler = (editorState) {
  final selection = editorState.selection;
  if (selection == null || !selection.isCollapsed) {
    return KeyEventResult.ignored;
  }
  final node = editorState.getNodeAtPath(selection.end.path);
  if (node == null) {
    return KeyEventResult.ignored;
  }

  final nextNode = node.next;
  Selection? afterSelection;
  if (nextNode != null && nextNode.delta != null) {
    afterSelection = Selection.collapsed(
      Position(path: node.path, offset: nextNode.delta?.length ?? 0),
    );
  }

  final transaction = editorState.transaction
    ..deleteNode(node)
    ..afterSelection = afterSelection;
  editorState.apply(transaction);

  return KeyEventResult.handled;
};
