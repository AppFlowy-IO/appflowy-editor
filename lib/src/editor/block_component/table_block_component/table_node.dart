import 'dart:math';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_config.dart';

class TableNode {
  final TableConfig _config;

  final Node node;
  final List<List<Node>> _cells = [];

  TableNode({
    required this.node,
  }) : _config = TableConfig.fromJson(node.attributes) {
    if (node.type != TableBlockKeys.type) {
      AppFlowyEditorLog.editor.debug('TableNode: node is not a table');
      return;
    }

    final attributes = node.attributes;
    final colsLen = attributes[TableBlockKeys.colsLen];
    final rowsLen = attributes[TableBlockKeys.rowsLen];

    if (colsLen == null ||
        rowsLen == null ||
        colsLen is! int ||
        rowsLen is! int) {
      AppFlowyEditorLog.editor.debug(
        'TableNode: colsLen or rowsLen is not an integer or null',
      );
      return;
    }

    if (node.children.length != colsLen * rowsLen) {
      AppFlowyEditorLog.editor.debug(
        'TableNode: the number of children is not equal to the number of cells',
      );
      return;
    }

    // every cell should has rowPosition and colPosition to indicate its position in the table
    for (final child in node.children) {
      if (!child.attributes.containsKey(TableCellBlockKeys.rowPosition) ||
          !child.attributes.containsKey(TableCellBlockKeys.colPosition)) {
        AppFlowyEditorLog.editor
            .debug('TableNode: cell has no rowPosition or colPosition');
        return;
      }
    }

    for (var i = 0; i < colsLen; i++) {
      _cells.add([]);
      for (var j = 0; j < rowsLen; j++) {
        final cell = node.children
            .where(
              (n) =>
                  n.attributes[TableCellBlockKeys.colPosition] == i &&
                  n.attributes[TableCellBlockKeys.rowPosition] == j,
            )
            .firstOrNull;

        if (cell == null) {
          AppFlowyEditorLog.editor.debug('TableNode: cell is empty');
          _cells.clear();
          return;
        }

        _cells[i].add(newCellNode(node, cell));
      }
    }
  }

  factory TableNode.fromJson(Map<String, Object> json) {
    return TableNode(node: Node.fromJson(json));
  }

  static TableNode fromList<T>(List<List<T>> cols, {TableConfig? config}) {
    assert(
      T == String ||
          (T == Node &&
              cols.every(
                (col) => col.every((n) => (n as Node).delta != null),
              )),
    );
    assert(cols.isNotEmpty);
    assert(cols[0].isNotEmpty);
    assert(cols.every((col) => col.length == cols[0].length));

    config = config ?? TableConfig();

    Node node = Node(
      type: TableBlockKeys.type,
      attributes: {}
        ..addAll({
          TableBlockKeys.colsLen: cols.length,
          TableBlockKeys.rowsLen: cols[0].length,
        })
        ..addAll(config.toJson()),
    );
    for (var i = 0; i < cols.length; i++) {
      for (var j = 0; j < cols[0].length; j++) {
        final cell = Node(
          type: TableCellBlockKeys.type,
          attributes: {
            TableCellBlockKeys.colPosition: i,
            TableCellBlockKeys.rowPosition: j,
          },
        );

        late Node cellChild;
        if (T == String) {
          cellChild = paragraphNode(
            delta: Delta()..insert(cols[i][j] as String),
          );
        } else {
          cellChild = cols[i][j] as Node;
        }
        cell.insert(cellChild);

        node.insert(cell);
      }
    }

    return TableNode(node: node);
  }

  Node getCell(int col, row) => _cells[col][row];

  TableConfig get config => _config;

  int get colsLen => _cells.length;

  int get rowsLen => _cells.isNotEmpty ? _cells[0].length : 0;

  double getRowHeight(int row) =>
      double.tryParse(
        _cells[0][row].attributes[TableCellBlockKeys.height].toString(),
      ) ??
      _config.rowDefaultHeight;

  double get colsHeight =>
      List.generate(rowsLen, (idx) => idx).fold<double>(
        0,
        (prev, cur) => prev + getRowHeight(cur) + _config.borderWidth,
      ) +
      _config.borderWidth;

  double getColWidth(int col) =>
      double.tryParse(
        _cells[col][0].attributes[TableCellBlockKeys.width].toString(),
      ) ??
      _config.colDefaultWidth;

  double get tableWidth =>
      List.generate(colsLen, (idx) => idx).fold<double>(
        0,
        (prev, cur) => prev + getColWidth(cur) + _config.borderWidth,
      ) +
      _config.borderWidth;

  void setColWidth(
    int col,
    double w, {
    Transaction? transaction,
    bool force = false,
  }) {
    w = w < _config.colMinimumWidth ? _config.colMinimumWidth : w;
    if (getColWidth(col) != w || force) {
      for (int i = 0; i < rowsLen; i++) {
        if (transaction != null) {
          transaction.updateNode(_cells[col][i], {TableCellBlockKeys.width: w});
        } else {
          _cells[col][i].updateAttributes({TableCellBlockKeys.width: w});
        }
        updateRowHeight(i, transaction: transaction);
      }
      if (transaction != null) {
        transaction.updateNode(node, node.attributes);
      } else {
        node.updateAttributes(node.attributes);
      }
    }
  }

  void updateRowHeight(
    int row, {
    EditorState? editorState,
    Transaction? transaction,
  }) {
    // The extra 8 is because of paragraph padding
    double maxHeight = _cells
        .map<double>((c) => c[row].children.first.rect.height + 8)
        .reduce(max);

    if (_cells[0][row].attributes[TableCellBlockKeys.height] != maxHeight &&
        !maxHeight.isNaN) {
      for (int i = 0; i < colsLen; i++) {
        final currHeight = _cells[i][row].attributes[TableCellBlockKeys.height];
        if (currHeight == maxHeight) {
          continue;
        }

        if (transaction != null) {
          transaction.updateNode(
            _cells[i][row],
            {TableCellBlockKeys.height: maxHeight},
          );
        } else {
          _cells[i][row].updateAttributes(
            {TableCellBlockKeys.height: maxHeight},
          );
        }
      }
    }

    if (node.attributes[TableBlockKeys.colsHeight] != colsHeight &&
        !colsHeight.isNaN) {
      if (transaction != null) {
        transaction.updateNode(node, {TableBlockKeys.colsHeight: colsHeight});
        if (editorState != null && editorState.editable != true) {
          node.updateAttributes({TableBlockKeys.colsHeight: colsHeight});
        }
      } else {
        node.updateAttributes({TableBlockKeys.colsHeight: colsHeight});
      }
    }
  }
}
