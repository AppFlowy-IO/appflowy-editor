import 'package:flutter/material.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/util.dart';

final List<CommandShortcutEvent> tableCommands = [
  _enterInTableCell,
  _leftInTableCell,
  _rightInTableCell,
  _upInTableCell,
  _downInTableCell,
];

final CommandShortcutEvent _enterInTableCell = CommandShortcutEvent(
  key: 'Don\'t add new line in table cell',
  command: 'enter',
  handler: _enterInTableCellHandler,
);

final CommandShortcutEvent _leftInTableCell = CommandShortcutEvent(
  key: 'Move to left cell if its at start of current cell',
  command: 'arrow left',
  handler: _leftInTableCellHandler,
);

final CommandShortcutEvent _rightInTableCell = CommandShortcutEvent(
  key: 'Move to right cell if its at the end of current cell',
  command: 'arrow right',
  handler: _rightInTableCellHandler,
);

final CommandShortcutEvent _upInTableCell = CommandShortcutEvent(
  key: 'Move to up cell at same offset',
  command: 'arrow up',
  handler: _upInTableCellHandler,
);

final CommandShortcutEvent _downInTableCell = CommandShortcutEvent(
  key: 'Move to down cell at same offset',
  command: 'arrow down',
  handler: _downInTableCellHandler,
);

CommandShortcutEventHandler _enterInTableCellHandler = (editorState) {
  final inTableNodes = _inTableNodes(editorState);
  if (inTableNodes.isEmpty) {
    return KeyEventResult.ignored;
  }

  final selection = editorState.selection;
  if (_hasSelectionAndTableCell(inTableNodes, selection)) {
    final cell = inTableNodes.first.parent!;
    final nextNode = _getNextNode(inTableNodes, 0, 1);
    if (nextNode == null) {
      final transaction = editorState.transaction;
      transaction.insertNode(cell.parent!.path.next, paragraphNode());
      transaction.afterSelection =
          Selection.single(path: cell.parent!.path.next, startOffset: 0);
      editorState.apply(transaction);
    } else if (_nodeHasTextChild(nextNode)) {
      editorState.selectionService.updateSelection(
        Selection.single(
          path: nextNode.childAtIndexOrNull(0)!.path,
          startOffset: 0,
        ),
      );
    }
  }
  return KeyEventResult.handled;
};

CommandShortcutEventHandler _leftInTableCellHandler = (editorState) {
  final inTableNodes = _inTableNodes(editorState);
  final selection = editorState.selection;
  if (_hasSelectionAndTableCell(inTableNodes, selection) &&
      selection!.start.offset == 0) {
    final nextNode = _getNextNode(inTableNodes, -1, 0);
    if (_nodeHasTextChild(nextNode)) {
      final target = nextNode!.childAtIndexOrNull(0)!;
      editorState.selectionService.updateSelection(
        Selection.single(
          path: target.path,
          startOffset: target.delta!.length,
        ),
      );
    }
    return KeyEventResult.handled;
  }
  return KeyEventResult.ignored;
};

CommandShortcutEventHandler _rightInTableCellHandler = (editorState) {
  final inTableNodes = _inTableNodes(editorState);
  final selection = editorState.selection;
  if (_hasSelectionAndTableCell(inTableNodes, selection) &&
      selection!.start.offset == inTableNodes.first.delta!.length) {
    final nextNode = _getNextNode(inTableNodes, 1, 0);
    if (_nodeHasTextChild(nextNode)) {
      editorState.selectionService.updateSelection(
        Selection.single(
          path: nextNode!.childAtIndexOrNull(0)!.path,
          startOffset: 0,
        ),
      );
    }
    return KeyEventResult.handled;
  }
  return KeyEventResult.ignored;
};

CommandShortcutEventHandler _upInTableCellHandler = (editorState) {
  final inTableNodes = _inTableNodes(editorState);
  final selection = editorState.selection;
  if (_hasSelectionAndTableCell(inTableNodes, selection)) {
    final nextNode = _getNextNode(inTableNodes, 0, -1);
    if (_nodeHasTextChild(nextNode)) {
      final target = nextNode!.childAtIndexOrNull(0)!;
      final off = target.delta!.length > selection!.start.offset
          ? selection.start.offset
          : target.delta!.length;
      editorState.selectionService.updateSelection(
        Selection.single(path: target.path, startOffset: off),
      );
    }
    return KeyEventResult.handled;
  }
  return KeyEventResult.ignored;
};

CommandShortcutEventHandler _downInTableCellHandler = (editorState) {
  final inTableNodes = _inTableNodes(editorState);
  final selection = editorState.selection;
  if (_hasSelectionAndTableCell(inTableNodes, selection)) {
    final nextNode = _getNextNode(inTableNodes, 0, 1);
    if (_nodeHasTextChild(nextNode)) {
      final target = nextNode!.childAtIndexOrNull(0)!;
      final off = target.delta!.length > selection!.start.offset
          ? selection.start.offset
          : target.delta!.length;
      editorState.selectionService.updateSelection(
        Selection.single(path: target.path, startOffset: off),
      );
    }
    return KeyEventResult.handled;
  }
  return KeyEventResult.ignored;
};

Iterable<Node> _inTableNodes(EditorState editorState) {
  final nodes = editorState.selectionService.currentSelectedNodes;
  return nodes.where((node) => node.type == ParagraphBlockKeys.type).where(
        (node) => node.parent?.type.contains(TableBlockKeys.type) ?? false,
      );
}

bool _hasSelectionAndTableCell(
  Iterable<Node> nodes,
  Selection? selection,
) =>
    nodes.length == 1 &&
    selection != null &&
    selection.isCollapsed &&
    nodes.first.parent?.type == 'table/cell';

Node? _getNextNode(Iterable<Node> nodes, int colDiff, rowDiff) {
  final cell = nodes.first.parent!;
  final col = cell.attributes['colPosition'];
  final row = cell.attributes['rowPosition'];
  return cell.parent != null
      ? getCellNode(cell.parent!, col + colDiff, row + rowDiff)
      : null;
}

bool _nodeHasTextChild(Node? n) =>
    n != null &&
    n.children.isNotEmpty &&
    n.childAtIndexOrNull(0)!.type == ParagraphBlockKeys.type;
