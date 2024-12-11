import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final indentableBlockTypes = {
  BulletedListBlockKeys.type,
  NumberedListBlockKeys.type,
  TodoListBlockKeys.type,
  ParagraphBlockKeys.type,
};

/// Indent the current block
///
/// - support
///   - desktop
///   - web
///
final CommandShortcutEvent indentCommand = CommandShortcutEvent(
  key: 'indent',
  getDescription: () => AppFlowyEditorL10n.current.cmdIndent,
  command: 'tab',
  handler: _indentCommandHandler,
);

bool isIndentable(EditorState editorState) {
  final selection = editorState.selection;
  if (selection == null) {
    return false;
  }

  List<Node> nodes = editorState.getNodesInSelection(selection).normalized;
  if (nodes.isEmpty) {
    return false;
  }

  final previous = nodes.firstOrNull?.previous;
  if (previous == null || !indentableBlockTypes.contains(previous.type)) {
    return false;
  }

  // there's no need to consider the child nodes
  // since we are ignoring child nodes, all nodes will be on same level
  nodes =
      nodes.where((node) => node.path.length == previous.path.length).toList();

  final isAllIndentable = nodes.every(
    (node) => indentableBlockTypes.contains(node.type),
  );
  if (!isAllIndentable) {
    return false;
  }

  return true;
}

CommandShortcutEventHandler _indentCommandHandler = (editorState) {
  final selection = editorState.selection?.normalized;

  if (selection == null) {
    return KeyEventResult.ignored;
  }

  if (!isIndentable(editorState)) {
    // ignore the system default tab behavior
    return KeyEventResult.handled;
  }

  List<Node> nodes = editorState.getNodesInSelection(selection).normalized;
  final previous = nodes.firstOrNull?.previous;

  if (previous == null) {
    return KeyEventResult.ignored;
  }

  // keep the nodes in the same level as the previous block
  nodes =
      nodes.where((node) => node.path.length == previous.path.length).toList();

  final startPath = previous.path + [previous.children.length];
  final endPath = previous.path + [previous.children.length + nodes.length - 1];

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
