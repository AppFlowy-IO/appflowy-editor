import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// Arrow down key events.
///
/// - support
///   - desktop
///   - web
///

// toggle the todo list
final CommandShortcutEvent toggleTodoListCommand = CommandShortcutEvent(
  key: 'toggle the todo list',
  command: 'ctrl+enter',
  macOSCommand: 'cmd+enter',
  handler: _toggleTodoListCommandHandler,
);

CommandShortcutEventHandler _toggleTodoListCommandHandler = (editorState) {
  if (PlatformExtension.isMobile) {
    assert(false, 'enter key is not supported on mobile platform.');
    return KeyEventResult.ignored;
  }

  final selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }
  final nodes = editorState.getNodesInSelection(selection);
  final todoNodes = nodes.where((element) => element.type == 'todo_list');
  if (todoNodes.isEmpty) {
    return KeyEventResult.ignored;
  }

  final areAllTodoListChecked = todoNodes
      .every((node) => node.attributes[TodoListBlockKeys.checked] == true);

  final transaction = editorState.transaction;
  for (final node in todoNodes) {
    transaction.updateNode(node, {
      TodoListBlockKeys.checked: !areAllTodoListChecked,
    });
  }
  transaction.afterSelection = selection;
  editorState.apply(transaction);
  return KeyEventResult.handled;
};
