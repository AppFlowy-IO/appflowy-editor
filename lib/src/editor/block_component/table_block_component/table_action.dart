import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/util.dart';

class TableActions {
  const TableActions._();

  static void add(
    Node node,
    int position,
    Transaction transaction,
    TableDirection dir,
  ) {
    if (dir == TableDirection.col) {
      _addCol(node, position, transaction);
    } else {
      _addRow(node, position, transaction);
    }
  }

  static void delete(
    Node node,
    int position,
    Transaction transaction,
    TableDirection dir,
  ) {
    if (dir == TableDirection.col) {
      _deleteCol(node, position, transaction);
    } else {
      _deleteRow(node, position, transaction);
    }
  }

  static void duplicate(
    Node node,
    int position,
    Transaction transaction,
    TableDirection dir,
  ) {
    if (dir == TableDirection.col) {
      _duplicateCol(node, position, transaction);
    } else {
      _duplicateRow(node, position, transaction);
    }
  }

  static void clear(
    Node node,
    int position,
    Transaction transaction,
    TableDirection dir,
  ) {
    if (dir == TableDirection.col) {
      _clearCol(node, position, transaction);
    } else {
      _clearRow(node, position, transaction);
    }
  }

  static void setBgColor(
    Node node,
    int position,
    Transaction transaction,
    String? color,
    TableDirection dir,
  ) {
    if (dir == TableDirection.col) {
      _setColBgColor(node, position, transaction, color);
    } else {
      _setRowBgColor(node, position, transaction, color);
    }
  }
}

void _addCol(Node tableNode, int position, Transaction transaction) {
  assert(position >= 0);

  List<Node> cellNodes = [];
  final int rowsLen = tableNode.attributes[TableBlockKeys.rowsLen],
      colsLen = tableNode.attributes[TableBlockKeys.colsLen];

  if (position != colsLen) {
    for (var i = position; i < colsLen; i++) {
      for (var j = 0; j < rowsLen; j++) {
        final node = getCellNode(tableNode, i, j)!;
        transaction.updateNode(node, {TableBlockKeys.colPosition: i + 1});
      }
    }
  }

  for (var i = 0; i < rowsLen; i++) {
    final node = Node(
      type: TableCellBlockKeys.type,
      attributes: {
        TableBlockKeys.colPosition: position,
        TableBlockKeys.rowPosition: i,
      },
    );
    node.insert(paragraphNode());

    cellNodes.add(newCellNode(tableNode, node));
  }

  late Path insertPath;
  if (position == 0) {
    insertPath = getCellNode(tableNode, 0, 0)!.path;
  } else {
    insertPath = getCellNode(tableNode, position - 1, rowsLen - 1)!.path.next;
  }
  // TODO(zoli): this calls notifyListener rowsLen+1 times. isn't there a better
  // way?
  transaction.insertNodes(insertPath, cellNodes);
  transaction.updateNode(tableNode, {TableBlockKeys.colsLen: colsLen + 1});
}

void _addRow(Node tableNode, int position, Transaction transaction) {
  assert(position >= 0);

  final int rowsLen = tableNode.attributes[TableBlockKeys.rowsLen],
      colsLen = tableNode.attributes[TableBlockKeys.colsLen];

  if (position != rowsLen) {
    for (var i = position; i < rowsLen; i++) {
      for (var j = 0; j < colsLen; j++) {
        final node = getCellNode(tableNode, j, i)!;
        transaction.updateNode(node, {TableBlockKeys.rowPosition: i + 1});
      }
    }
  }

  for (var i = 0; i < colsLen; i++) {
    final node = Node(
      type: TableCellBlockKeys.type,
      attributes: {
        TableBlockKeys.colPosition: i,
        TableBlockKeys.rowPosition: position,
      },
    );
    node.insert(paragraphNode());

    late Path insertPath;
    if (position == 0) {
      insertPath = getCellNode(tableNode, i, 0)!.path;
    } else {
      insertPath = getCellNode(tableNode, i, position - 1)!.path.next;
    }
    transaction.insertNode(
      insertPath,
      newCellNode(tableNode, node),
    );
  }
  transaction.updateNode(tableNode, {TableBlockKeys.rowsLen: rowsLen + 1});
}

void _deleteCol(Node tableNode, int col, Transaction transaction) {
  final int rowsLen = tableNode.attributes[TableBlockKeys.rowsLen],
      colsLen = tableNode.attributes[TableBlockKeys.colsLen];
  List<Node> nodes = [];
  for (var i = 0; i < rowsLen; i++) {
    nodes.add(getCellNode(tableNode, col, i)!);
  }
  transaction.deleteNodes(nodes);

  _updateCellPositions(tableNode, transaction, col + 1, 0, -1, 0);

  transaction.updateNode(tableNode, {TableBlockKeys.colsLen: colsLen - 1});
}

void _deleteRow(Node tableNode, int row, Transaction transaction) {
  final int rowsLen = tableNode.attributes[TableBlockKeys.rowsLen],
      colsLen = tableNode.attributes[TableBlockKeys.colsLen];
  List<Node> nodes = [];
  for (var i = 0; i < colsLen; i++) {
    nodes.add(getCellNode(tableNode, i, row)!);
  }
  transaction.deleteNodes(nodes);

  _updateCellPositions(tableNode, transaction, 0, row + 1, 0, -1);

  transaction.updateNode(tableNode, {TableBlockKeys.rowsLen: rowsLen - 1});
}

void _duplicateCol(Node tableNode, int col, Transaction transaction) {
  final int rowsLen = tableNode.attributes[TableBlockKeys.rowsLen],
      colsLen = tableNode.attributes[TableBlockKeys.colsLen];
  List<Node> nodes = [];
  for (var i = 0; i < rowsLen; i++) {
    final node = getCellNode(tableNode, col, i)!;
    nodes.add(
      node.copyWith(
        attributes: {
          ...node.attributes,
          TableBlockKeys.colPosition: col + 1,
          TableBlockKeys.rowPosition: i,
        },
      ),
    );
  }
  transaction.insertNodes(
    getCellNode(tableNode, col, rowsLen - 1)!.path.next,
    nodes,
  );

  _updateCellPositions(tableNode, transaction, col + 1, 0, 1, 0);

  transaction.updateNode(tableNode, {TableBlockKeys.colsLen: colsLen + 1});
}

void _duplicateRow(Node tableNode, int row, Transaction transaction) {
  final int rowsLen = tableNode.attributes[TableBlockKeys.rowsLen],
      colsLen = tableNode.attributes[TableBlockKeys.colsLen];
  for (var i = 0; i < colsLen; i++) {
    final node = getCellNode(tableNode, i, row)!;
    transaction.insertNode(
      node.path.next,
      node.copyWith(
        attributes: {
          ...node.attributes,
          TableBlockKeys.rowPosition: row + 1,
          TableBlockKeys.colPosition: i,
        },
      ),
    );
  }

  _updateCellPositions(tableNode, transaction, 0, row + 1, 0, 1);

  transaction.updateNode(tableNode, {TableBlockKeys.rowsLen: rowsLen + 1});
}

void _setColBgColor(
  Node tableNode,
  int col,
  Transaction transaction,
  String? color,
) {
  final rowslen = tableNode.attributes[TableBlockKeys.rowsLen];
  for (var i = 0; i < rowslen; i++) {
    final node = getCellNode(tableNode, col, i)!;
    transaction.updateNode(
      node,
      {TableBlockKeys.backgroundColor: color},
    );
  }
}

void _setRowBgColor(
  Node tableNode,
  int row,
  Transaction transaction,
  String? color,
) {
  final colsLen = tableNode.attributes[TableBlockKeys.colsLen];
  for (var i = 0; i < colsLen; i++) {
    final node = getCellNode(tableNode, i, row)!;
    transaction.updateNode(
      node,
      {TableBlockKeys.backgroundColor: color},
    );
  }
}

void _clearCol(
  Node tableNode,
  int col,
  Transaction transaction,
) {
  final rowsLen = tableNode.attributes[TableBlockKeys.rowsLen];
  for (var i = 0; i < rowsLen; i++) {
    final node = getCellNode(tableNode, col, i)!;
    transaction.insertNode(
      node.children.first.path,
      paragraphNode(text: ''),
    );
  }
}

void _clearRow(
  Node tableNode,
  int row,
  Transaction transaction,
) {
  final colsLen = tableNode.attributes[TableBlockKeys.colsLen];
  for (var i = 0; i < colsLen; i++) {
    final node = getCellNode(tableNode, i, row)!;
    transaction.insertNode(
      node.children.first.path,
      paragraphNode(text: ''),
    );
  }
}

dynamic newCellNode(Node tableNode, n) {
  final row = n.attributes[TableBlockKeys.rowPosition] as int;
  final col = n.attributes[TableBlockKeys.colPosition] as int;
  final int rowsLen = tableNode.attributes[TableBlockKeys.rowsLen];
  final int colsLen = tableNode.attributes[TableBlockKeys.colsLen];

  if (!n.attributes.containsKey(TableBlockKeys.height)) {
    double nodeHeight = double.tryParse(
      tableNode.attributes[TableBlockKeys.rowDefaultHeight].toString(),
    )!;
    if (row < rowsLen) {
      nodeHeight = double.tryParse(
            getCellNode(tableNode, 0, row)!
                .attributes[TableBlockKeys.height]
                .toString(),
          ) ??
          nodeHeight;
    }
    n.updateAttributes({TableBlockKeys.height: nodeHeight});
  }

  if (!n.attributes.containsKey(TableBlockKeys.width)) {
    double nodeWidth = double.tryParse(
      tableNode.attributes[TableBlockKeys.colDefaultWidth].toString(),
    )!;
    if (col < colsLen) {
      nodeWidth = double.tryParse(
            getCellNode(tableNode, col, 0)!
                .attributes[TableBlockKeys.width]
                .toString(),
          ) ??
          nodeWidth;
    }
    n.updateAttributes({TableBlockKeys.width: nodeWidth});
  }

  return n;
}

void _updateCellPositions(
  Node tableNode,
  Transaction transaction,
  int fromCol,
  int fromRow,
  int addToCol,
  int addToRow,
) {
  final int rowsLen = tableNode.attributes[TableBlockKeys.rowsLen],
      colsLen = tableNode.attributes[TableBlockKeys.colsLen];

  for (var i = fromCol; i < colsLen; i++) {
    for (var j = fromRow; j < rowsLen; j++) {
      transaction.updateNode(getCellNode(tableNode, i, j)!, {
        TableBlockKeys.colPosition: i + addToCol,
        TableBlockKeys.rowPosition: j + addToRow,
      });
    }
  }
}
