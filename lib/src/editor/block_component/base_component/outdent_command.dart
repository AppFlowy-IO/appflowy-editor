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
  final selection = editorState.selection;
  if (selection == null) {
    return false;
  }

  List<Node> nodes = editorState.getNodesInSelection(selection).normalized;
  if (nodes.isEmpty) {
    return false;
  }

  final parent = nodes.firstOrNull?.parent;
  if (parent == null || !indentableBlockTypes.contains(parent.type)) {
    return false;
  }

  if (nodes.any((node) => node.path.length == 1)) {
    //  if the any nodes is having a path which is of size 1.
    //  for example [0], then that means, it is not indented
    //  thus we ignore this event.
    return false;
  }

  // keep only immediate children nodes of parent
  // since we are keeping only immediate children nodes, all nodes will be on same level
  nodes = nodes
      .where((node) => node.path.length == parent.path.length + 1)
      .toList();

  final isAllIndentable =
      nodes.every((node) => indentableBlockTypes.contains(node.type));
  if (!isAllIndentable) {
    return false;
  }

  return true;
}

CommandShortcutEventHandler _outdentCommandHandler = (editorState) {
  final selection = editorState.selection?.normalized;
  if (selection == null) {
    return KeyEventResult.ignored;
  }

  if (!isOutdentable(editorState)) {
    // ignore the system default tab behavior
    return KeyEventResult.handled;
  }

  List<Node> nodes = editorState.getNodesInSelection(selection).normalized;
  final parent = nodes.firstOrNull?.parent;

  if (parent == null) {
    return KeyEventResult.ignored;
  }

  // keep the nodes of the immediate children of parent node
  nodes = nodes
      .where((node) => node.path.length == parent.path.length + 1)
      .toList();

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
