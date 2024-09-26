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

  final nodes = editorState.getNodesInSelection(selection).normalized;
  final previous = nodes.firstOrNull?.previous;

  final isAllIndentable =
      nodes.every((node) => indentableBlockTypes.contains(node.type));

  final isAllOnSameLevel =
      nodes.every((node) => node.path.length == nodes.first.path.length);

  if (nodes.isEmpty ||
      previous == null ||
      !indentableBlockTypes.contains(previous.type) ||
      !isAllIndentable ||
      !isAllOnSameLevel) {
    return false;
  }
  return true;
}

CommandShortcutEventHandler _indentCommandHandler = (editorState) {
  final selection = editorState.selection?.normalized;

  if (selection == null) {
    return KeyEventResult.ignored;
  }

  final nodes = editorState.getNodesInSelection(selection).normalized;

  final isAllIndentable =
      nodes.every((node) => indentableBlockTypes.contains(node.type));

  final isAllOnSameLevel =
      nodes.every((node) => node.path.length == nodes.first.path.length);

  final previous = nodes.firstOrNull?.previous;

  if (previous == null ||
      !indentableBlockTypes.contains(previous.type) ||
      !isAllIndentable ||
      !isAllOnSameLevel) {
    return KeyEventResult.handled; // ignore the system default tab behavior
  }

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
