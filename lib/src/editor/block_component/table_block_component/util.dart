import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:collection/collection.dart';

Node? getCellNode(Node tableNode, int col, int row) {
  return tableNode.children.firstWhereOrNull(
    (n) =>
        n.attributes[TableCellBlockKeys.colPosition] == col &&
        n.attributes[TableCellBlockKeys.rowPosition] == row,
  );
}

extension TableCellNodeDynamicExtension on dynamic {
  double toDouble({double defaultValue = 0.0}) {
    if (this is int) {
      return this.toDouble();
    } else if (this is double) {
      return this;
    } else {
      return double.tryParse(toString()) ?? defaultValue;
    }
  }
}

extension TableCellNodeAttributesExtension on Node {
  double get cellWidth {
    assert(type == TableCellBlockKeys.type);
    return attributes[TableCellBlockKeys.width]?.toDouble() ??
        TableDefaults.colWidth;
  }

  double get cellHeight {
    assert(type == TableCellBlockKeys.type);
    return attributes[TableCellBlockKeys.height]?.toDouble() ??
        TableDefaults.rowHeight;
  }

  double get colHeight {
    assert(type == TableBlockKeys.type);
    return attributes[TableBlockKeys.colsHeight]?.toDouble() ??
        TableDefaults.rowHeight;
  }
}
