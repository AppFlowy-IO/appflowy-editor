import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// Outdent the current block
///
/// - support
///   - desktop
///   - web
///
final CommandShortcutEvent outdentCommand = CommandShortcutEvent(
  key: 'indent',
  command: 'shift+tab',
  handler: _outdentCommandHandler,
);

CommandShortcutEventHandler _outdentCommandHandler = (editorState) {
  final selection = editorState.selection;
  if (selection == null || !selection.isCollapsed) {
    return KeyEventResult.ignored;
  }
  final node = editorState.getNodeAtPath(selection.end.path);
  final parent = node?.parent;
  if (node == null ||
      parent == null ||
      !indentableBlockTypes.contains(node.type) ||
      !indentableBlockTypes.contains(parent.type) ||
      node.path.length == 1) {
    //  if the current node is having a path which is of size 1.
    //  for example [0], then that means, it is not indented
    //  thus we ignore this event.
    return KeyEventResult.handled; // ignore the system default tab behavior
  }

  final path = node.path.sublist(0, node.path.length - 1)..last += 1;
  final afterSelection = Selection(
    start: selection.start.copyWith(path: path),
    end: selection.end.copyWith(path: path),
  );
  final transaction = editorState.transaction
    ..deleteNode(node)
    ..insertNode(path, node, deepCopy: true)
    ..afterSelection = afterSelection;
  editorState.apply(transaction);

  return KeyEventResult.handled;
};
