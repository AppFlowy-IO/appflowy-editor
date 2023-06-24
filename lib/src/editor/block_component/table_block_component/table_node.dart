import 'dart:math';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_action.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_config.dart';

class TableNode {
  final TableConfig _config;

  final Node node;
  final List<List<Node>> _cells = [];

  TableNode({
    required this.node,
  }) : _config = TableConfig.fromJson(node.attributes) {
    assert(node.type == TableBlockKeys.type);
    assert(node.attributes.containsKey('colsLen'));
    assert(node.attributes['colsLen'] is int);
    assert(node.attributes.containsKey('rowsLen'));
    assert(node.attributes['rowsLen'] is int);

    assert(node.attributes['rowDefaultHeight'] != null);
    assert(node.attributes['colMinimumWidth'] != null);
    assert(node.attributes['colDefaultWidth'] != null);

    final int colsCount = node.attributes['colsLen'];
    final int rowsCount = node.attributes['rowsLen'];
    assert(node.children.length == colsCount * rowsCount);
    assert(
      node.children.every(
        (n) =>
            n.attributes.containsKey('rowPosition') &&
            n.attributes.containsKey('colPosition'),
      ),
    );
    assert(
      node.children.every(
        (n) =>
            n.attributes.containsKey('rowPosition') &&
            n.attributes.containsKey('colPosition'),
      ),
    );

    for (var i = 0; i < colsCount; i++) {
      _cells.add([]);
      for (var j = 0; j < rowsCount; j++) {
        final cell = node.children.where(
          (n) =>
              n.attributes['colPosition'] == i &&
              n.attributes['rowPosition'] == j,
        );
        assert(cell.length == 1);
        _cells[i].add(newCellNode(node, cell.first));
      }
    }
  }

  factory TableNode.fromJson(Map<String, Object> json) {
    return TableNode(node: Node.fromJson(json));
  }

  static TableNode fromList<T>(List<List<T>> cols, {TableConfig? config}) {
    // assert(T == String || T == TextNode);
    assert(cols.isNotEmpty);
    assert(cols[0].isNotEmpty);
    assert(cols.every((col) => col.length == cols[0].length));

    config = config ?? const TableConfig();

    Node node = Node(
      type: TableBlockKeys.type,
      attributes: {}
        ..addAll({
          'colsLen': cols.length,
          'rowsLen': cols[0].length,
        })
        ..addAll(config.toJson()),
    );
    for (var i = 0; i < cols.length; i++) {
      for (var j = 0; j < cols[0].length; j++) {
        final n = Node(
          type: TableCellBlockKeys.type,
          attributes: {'colPosition': i, 'rowPosition': j},
        );
        if (T == String) {
          n.insert(
            paragraphNode(
              delta: Delta()..insert(cols[i][j] as String),
            ),
          );
        }

        node.insert(n);
      }
    }

    return TableNode(node: node);
  }

  Node getCell(int col, row) => _cells[col][row];

  TableConfig get config => _config.clone();

  int get colsLen => _cells.length;

  int get rowsLen => _cells.isNotEmpty ? _cells[0].length : 0;

  double getRowHeight(int row) =>
      double.tryParse(_cells[0][row].attributes['height'].toString()) ??
      _config.rowDefaultHeight;

  double get colsHeight =>
      List.generate(rowsLen, (idx) => idx).fold<double>(
        0,
        (prev, cur) => prev + getRowHeight(cur) + _config.tableBorderWidth,
      ) +
      _config.tableBorderWidth;

  double getColWidth(int col) =>
      double.tryParse(_cells[col][0].attributes['width'].toString()) ??
      _config.colDefaultWidth;

  double get tableWidth =>
      List.generate(colsLen, (idx) => idx).fold<double>(
        0,
        (prev, cur) => prev + getColWidth(cur) + _config.tableBorderWidth,
      ) +
      _config.tableBorderWidth;

  void setColWidth(int col, double w) {
    w = w < _config.colMinimumWidth ? _config.colMinimumWidth : w;
    if (getColWidth(col) != w) {
      for (var i = 0; i < rowsLen; i++) {
        _cells[col][i].updateAttributes({'width': w});
      }
      for (var i = 0; i < rowsLen; i++) {
        updateRowHeight(i);
      }
      node.updateAttributes({});
    }
  }

  void updateRowHeight(int row) {
    // The extra 8 is because of paragraph padding
    double maxHeight = _cells
        .map<double>((c) => c[row].children.first.rect.height + 8)
        .reduce(max);

    if (_cells[0][row].attributes['height'] != maxHeight) {
      for (var i = 0; i < colsLen; i++) {
        _cells[i][row].updateAttributes({'height': maxHeight});
      }
    }

    if (node.attributes['colsHeight'] != colsHeight) {
      node.updateAttributes({'colsHeight': colsHeight});
    }
  }
}
