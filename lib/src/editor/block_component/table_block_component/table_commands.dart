import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/util.dart';
import 'package:flutter/material.dart';

final List<CommandShortcutEvent> tableCommands = [
  _enterInTableCell,
  _leftInTableCell,
  _rightInTableCell,
  _upInTableCell,
  _downInTableCell,
  _tabInTableCell,
  _shiftTabInTableCell,
  _backSpaceInTableCell,
];

final CommandShortcutEvent _enterInTableCell = CommandShortcutEvent(
  key: 'Don\'t add new line in table cell',
  getDescription: () => AppFlowyEditorL10n.current.cmdTableLineBreak,
  command: 'enter',
  handler: _enterInTableCellHandler,
);

final CommandShortcutEvent _leftInTableCell = CommandShortcutEvent(
  key: 'Move to left cell if its at start of current cell',
  getDescription: () => AppFlowyEditorL10n
      .current.cmdTableMoveToLeftCellIfItsAtStartOfCurrentCell,
  command: 'arrow left',
  handler: _leftInTableCellHandler,
);

final CommandShortcutEvent _rightInTableCell = CommandShortcutEvent(
  key: 'Move to right cell if its at the end of current cell',
  getDescription: () => AppFlowyEditorL10n
      .current.cmdTableMoveToRightCellIfItsAtTheEndOfCurrentCell,
  command: 'arrow right',
  handler: _rightInTableCellHandler,
);

final CommandShortcutEvent _upInTableCell = CommandShortcutEvent(
  key: 'Move to up cell at same offset',
  getDescription: () =>
      AppFlowyEditorL10n.current.cmdTableMoveToUpCellAtSameOffset,
  command: 'arrow up',
  handler: _upInTableCellHandler,
);

final CommandShortcutEvent _downInTableCell = CommandShortcutEvent(
  key: 'Move to down cell at same offset',
  getDescription: () =>
      AppFlowyEditorL10n.current.cmdTableMoveToDownCellAtSameOffset,
  command: 'arrow down',
  handler: _downInTableCellHandler,
);

final CommandShortcutEvent _tabInTableCell = CommandShortcutEvent(
  key: 'Navigate around the cells at same offset',
  getDescription: () => AppFlowyEditorL10n.current.cmdTableNavigateCells,
  command: 'tab',
  handler: _tabInTableCellHandler,
);

final CommandShortcutEvent _shiftTabInTableCell = CommandShortcutEvent(
  key: 'Navigate around the cells at same offset in reverse',
  getDescription: () => AppFlowyEditorL10n.current.cmdTableNavigateCellsReverse,
  command: 'shift+tab',
  handler: _shiftTabInTableCellHandler,
);

final CommandShortcutEvent _backSpaceInTableCell = CommandShortcutEvent(
  key: 'Stop at the beginning of the cell',
  getDescription: () =>
      AppFlowyEditorL10n.current.cmdTableStopAtTheBeginningOfTheCell,
  command: 'backspace',
  handler: _backspaceInTableCellHandler,
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
    final nextNode = _getPreviousNode(inTableNodes, 1, 0);
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

CommandShortcutEventHandler _tabInTableCellHandler = (editorState) {
  final inTableNodes = _inTableNodes(editorState);
  final selection = editorState.selection;
  if (_hasSelectionAndTableCell(inTableNodes, selection)) {
    final nextNode = _getNextNode(inTableNodes, 1, 0);
    if (nextNode != null && _nodeHasTextChild(nextNode)) {
      final firstChild = nextNode.childAtIndexOrNull(0);
      if (firstChild != null) {
        editorState.selection = Selection.single(
          path: firstChild.path,
          startOffset: 0,
        );
      }
    }
    return KeyEventResult.handled;
  }
  return KeyEventResult.ignored;
};

CommandShortcutEventHandler _shiftTabInTableCellHandler = (editorState) {
  final inTableNodes = _inTableNodes(editorState);
  final selection = editorState.selection;
  if (_hasSelectionAndTableCell(inTableNodes, selection)) {
    final previousNode = _getPreviousNode(inTableNodes, 1, 0);
    if (previousNode != null && _nodeHasTextChild(previousNode)) {
      final firstChild = previousNode.childAtIndexOrNull(0);
      if (firstChild != null) {
        editorState.selection = Selection.single(
          path: firstChild.path,
          startOffset: 0,
        );
      }
    }
    return KeyEventResult.handled;
  }
  return KeyEventResult.ignored;
};

CommandShortcutEventHandler _backspaceInTableCellHandler = (editorState) {
  final selection = editorState.selection;
  if (selection == null || !selection.isCollapsed) {
    return KeyEventResult.ignored;
  }

  final position = selection.start;
  final node = editorState.getNodeAtPath(position.path);
  if (node == null || node.delta == null) {
    return KeyEventResult.ignored;
  }

  if (node.parent?.type == TableCellBlockKeys.type && position.offset == 0) {
    return KeyEventResult.handled;
  }

  return KeyEventResult.ignored;
};

Iterable<Node> _inTableNodes(EditorState editorState) {
  final selection = editorState.selection;
  if (selection == null) {
    return [];
  }
  final nodes = editorState.getNodesInSelection(selection);
  return nodes.where(
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
    nodes.first.parent?.type == TableCellBlockKeys.type;

Node? _getNextNode(Iterable<Node> nodes, int colDiff, int rowDiff) {
  final cell = nodes.first.parent!;
  final col = cell.attributes[TableCellBlockKeys.colPosition];
  final row = cell.attributes[TableCellBlockKeys.rowPosition];
  final table = cell.parent;
  if (table == null) {
    return null;
  }

  final numCols =
      table.children.last.attributes[TableCellBlockKeys.colPosition] + 1;
  final numRows =
      table.children.last.attributes[TableCellBlockKeys.rowPosition] + 1;

  // Calculate the next column index, considering the column difference and wrapping around with modulo.
  var nextCol = (col + colDiff) % numCols;

  // Calculate the next row index, taking into account the row difference and adjusting for additional rows due to column change.
  var nextRow = row + rowDiff + ((col + colDiff) ~/ numCols);

  return isValidPosition(nextCol, nextRow, numCols, numRows)
      ? getCellNode(table, nextCol, nextRow)
      : null;
}

Node? _getPreviousNode(Iterable<Node> nodes, int colDiff, int rowDiff) {
  final cell = nodes.first.parent!;
  final col = cell.attributes[TableCellBlockKeys.colPosition];
  final row = cell.attributes[TableCellBlockKeys.rowPosition];
  final table = cell.parent;
  if (table == null) {
    return null;
  }

  final numCols =
      table.children.last.attributes[TableCellBlockKeys.colPosition] + 1;
  final numRows =
      table.children.last.attributes[TableCellBlockKeys.rowPosition] + 1;

  // Calculate the previous column index, ensuring it wraps within the table boundaries using modulo.
  var prevCol = (col - colDiff + numCols) % numCols;

  // Calculate the previous row index, considering table boundaries and adjusting for potential column underflow.
  var prevRow = row - rowDiff - ((col - colDiff) < 0 ? 1 : 0);

  return isValidPosition(prevCol, prevRow, numCols, numRows)
      ? getCellNode(table, prevCol, prevRow)
      : null;
}

bool isValidPosition(int col, int row, int numCols, int numRows) =>
    col >= 0 && col < numCols && row >= 0 && row < numRows;

bool _nodeHasTextChild(Node? n) =>
    n != null &&
    n.children.isNotEmpty &&
    n.childAtIndexOrNull(0)!.delta != null;
