import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/util.dart';

void addCol(Node tableNode, int position, Transaction transaction) {
  assert(position >= 0);

  List<Node> cellNodes = [];
  final int rowsLen = tableNode.attributes['rowsLen'],
      colsLen = tableNode.attributes['colsLen'];

  if (position != colsLen) {
    for (var i = position; i < colsLen; i++) {
      for (var j = 0; j < rowsLen; j++) {
        final node = getCellNode(tableNode, i, j)!;
        transaction.updateNode(node, {'colPosition': i + 1});
      }
    }
  }

  for (var i = 0; i < rowsLen; i++) {
    final node = Node(
      type: TableCellBlockKeys.type,
      attributes: {
        'colPosition': position,
        'rowPosition': i,
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
  transaction.updateNode(tableNode, {'colsLen': colsLen + 1});
}

void addRow(Node tableNode, int position, Transaction transaction) {
  assert(position >= 0);

  final int rowsLen = tableNode.attributes['rowsLen'],
      colsLen = tableNode.attributes['colsLen'];

  if (position != rowsLen) {
    for (var i = position; i < rowsLen; i++) {
      for (var j = 0; j < colsLen; j++) {
        final node = getCellNode(tableNode, j, i)!;
        transaction.updateNode(node, {'rowPosition': i + 1});
      }
    }
  }

  for (var i = 0; i < colsLen; i++) {
    final node = Node(
      type: TableCellBlockKeys.type,
      attributes: {
        'colPosition': i,
        'rowPosition': position,
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
  transaction.updateNode(tableNode, {'rowsLen': rowsLen + 1});
}

void removeCol(Node tableNode, int col, Transaction transaction) {
  final int rowsLen = tableNode.attributes['rowsLen'],
      colsLen = tableNode.attributes['colsLen'];
  List<Node> nodes = [];
  for (var i = 0; i < rowsLen; i++) {
    nodes.add(getCellNode(tableNode, col, i)!);
  }
  transaction.deleteNodes(nodes);

  _updateCellPositions(tableNode, transaction, col + 1, 0, -1, 0);

  transaction.updateNode(tableNode, {'colsLen': colsLen - 1});
}

void removeRow(Node tableNode, int row, Transaction transaction) {
  final int rowsLen = tableNode.attributes['rowsLen'],
      colsLen = tableNode.attributes['colsLen'];
  List<Node> nodes = [];
  for (var i = 0; i < colsLen; i++) {
    nodes.add(getCellNode(tableNode, i, row)!);
  }
  transaction.deleteNodes(nodes);

  _updateCellPositions(tableNode, transaction, 0, row + 1, 0, -1);

  transaction.updateNode(tableNode, {'rowsLen': rowsLen - 1});
}

void duplicateCol(Node tableNode, int col, Transaction transaction) {
  final int rowsLen = tableNode.attributes['rowsLen'],
      colsLen = tableNode.attributes['colsLen'];
  List<Node> nodes = [];
  for (var i = 0; i < rowsLen; i++) {
    final node = getCellNode(tableNode, col, i)!;
    nodes.add(
      node.copyWith(
        attributes: {
          ...node.attributes,
          'colPosition': col + 1,
          'rowPosition': i,
        },
      ),
    );
  }
  transaction.insertNodes(
    getCellNode(tableNode, col, rowsLen - 1)!.path.next,
    nodes,
  );

  _updateCellPositions(tableNode, transaction, col + 1, 0, 1, 0);

  transaction.updateNode(tableNode, {'colsLen': colsLen + 1});
}

void duplicateRow(Node tableNode, int row, Transaction transaction) {
  final int rowsLen = tableNode.attributes['rowsLen'],
      colsLen = tableNode.attributes['colsLen'];
  for (var i = 0; i < colsLen; i++) {
    final node = getCellNode(tableNode, i, row)!;
    transaction.insertNode(
      node.path.next,
      node.copyWith(
        attributes: {
          ...node.attributes,
          'rowPosition': row + 1,
          'colPosition': i,
        },
      ),
    );
  }

  _updateCellPositions(tableNode, transaction, 0, row + 1, 0, 1);

  transaction.updateNode(tableNode, {'rowsLen': rowsLen + 1});
}

void setColBgColor(
  Node tableNode,
  int col,
  Transaction transaction,
  String? color,
) {
  final rowslen = tableNode.attributes['rowsLen'];
  for (var i = 0; i < rowslen; i++) {
    final node = getCellNode(tableNode, col, i)!;
    transaction.updateNode(
      node,
      {'backgroundColor': color},
    );
  }
}

void setRowBgColor(
  Node tableNode,
  int row,
  Transaction transaction,
  String? color,
) {
  final colsLen = tableNode.attributes['colsLen'];
  for (var i = 0; i < colsLen; i++) {
    final node = getCellNode(tableNode, i, row)!;
    transaction.updateNode(
      node,
      {'backgroundColor': color},
    );
  }
}

void clearCol(
  Node tableNode,
  int col,
  Transaction transaction,
) {
  final rowsLen = tableNode.attributes['rowsLen'];
  for (var i = 0; i < rowsLen; i++) {
    final node = getCellNode(tableNode, col, i)!;
    transaction.insertNode(
      node.children.first.path,
      Node(
        type: 'paragraph',
        attributes: {'delta': (Delta()..insert('')).toJson()},
      ),
    );
  }
}

void clearRow(
  Node tableNode,
  int row,
  Transaction transaction,
) {
  final colsLen = tableNode.attributes['colsLen'];
  for (var i = 0; i < colsLen; i++) {
    final node = getCellNode(tableNode, i, row)!;
    transaction.insertNode(
      node.children.first.path,
      Node(
        type: 'paragraph',
        attributes: {'delta': (Delta()..insert('')).toJson()},
      ),
    );
  }
}

dynamic newCellNode(Node tableNode, n) {
  final row = n.attributes['rowPosition'] as int;
  final col = n.attributes['colPosition'] as int;
  final int rowsLen = tableNode.attributes['rowsLen'];
  final int colsLen = tableNode.attributes['colsLen'];

  if (!n.attributes.containsKey('height')) {
    double nodeHeight = double.tryParse(
      tableNode.attributes['rowDefaultHeight'].toString(),
    )!;
    if (row < rowsLen) {
      nodeHeight = double.tryParse(
            getCellNode(tableNode, 0, row)!.attributes['height'].toString(),
          ) ??
          nodeHeight;
    }
    n.updateAttributes({'height': nodeHeight});
  }

  if (!n.attributes.containsKey('width')) {
    double nodeWidth = double.tryParse(
      tableNode.attributes['colDefaultWidth'].toString(),
    )!;
    if (col < colsLen) {
      nodeWidth = double.tryParse(
            getCellNode(tableNode, col, 0)!.attributes['width'].toString(),
          ) ??
          nodeWidth;
    }
    n.updateAttributes({'width': nodeWidth});
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
  final int rowsLen = tableNode.attributes['rowsLen'],
      colsLen = tableNode.attributes['colsLen'];

  for (var i = fromCol; i < colsLen; i++) {
    for (var j = fromRow; j < rowsLen; j++) {
      transaction.updateNode(getCellNode(tableNode, i, j)!, {
        'colPosition': i + addToCol,
        'rowPosition': j + addToRow,
      });
    }
  }
}