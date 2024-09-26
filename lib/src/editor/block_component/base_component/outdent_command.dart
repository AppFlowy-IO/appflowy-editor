import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// Outdent the current block
///
/// - support
///   - desktop
///   - web
///
final CommandShortcutEvent outdentCommand = CommandShortcutEvent(
  key: 'outdent',
  getDescription: () => AppFlowyEditorL10n.current.cmdOutdent,
  command: 'shift+tab',
  handler: _outdentCommandHandler,
);

bool isOutdentable(EditorState editorState) {
  final selection = editorState.selection?.normalized;
  if (selection == null) {
    return false;
  }

  final nodes = editorState.getNodesInSelection(selection);
  final parent = nodes.firstOrNull?.parent;

  final isAllIndentable =
      nodes.every((node) => indentableBlockTypes.contains(node.type));

  final isAllOnSameLevel =
      nodes.every((node) => node.path.length == nodes.first.path.length);

  // final node = editorState.getNodeAtPath(selection.end.path);
  // final parent = node?.parent;
  if (nodes.isEmpty ||
      parent == null ||
      !indentableBlockTypes.contains(parent.type) ||
      !isAllIndentable ||
      !isAllOnSameLevel ||
      nodes.first.path.length == 1) {
    //  if the first node is having a path which is of size 1.
    //  since all nodes are in same level, thus we can check first element
    //  for example [0], then that means, it is not indented
    //  thus we ignore this event.
    return false;
  }
  return true;
}

CommandShortcutEventHandler _outdentCommandHandler = (editorState) {
  final selection = editorState.selection?.normalized;
  if (selection == null) {
    return KeyEventResult.ignored;
  }

  final nodes = editorState.getNodesInSelection(selection);
  final parent = nodes.firstOrNull?.parent;

  final isAllIndentable =
      nodes.every((node) => indentableBlockTypes.contains(node.type));
  final isAllOnSameLevel =
      nodes.every((node) => node.path.length == nodes.first.path.length);

  if (nodes.isEmpty ||
      parent == null ||
      !indentableBlockTypes.contains(parent.type) ||
      !isAllIndentable ||
      !isAllOnSameLevel ||
      nodes.first.path.length == 1) {
    //  if the first node is having a path which is of size 1.
    //  since all nodes are in same level, thus we can check first element
    //  for example [0], then that means, it is not indented
    //  thus we ignore this event.
    return KeyEventResult.handled; // ignore the system default tab behavior
  }

  final startPath = nodes.first.path.sublist(0, nodes.first.path.length - 1)
    ..last += 1;
  final endPath = nodes.last.path.sublist(0, nodes.last.path.length - 1)
    ..last += nodes.length;
  final afterSelection = Selection(
    start: selection.start.copyWith(path: startPath),
    end: selection.end.copyWith(path: endPath),
  );
  final transaction = editorState.transaction
    ..deleteNodes(nodes)
    ..insertNodes(startPath, nodes, deepCopy: true)
    ..afterSelection = afterSelection;
  editorState.apply(transaction);

  return KeyEventResult.handled;
};
