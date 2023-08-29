import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:collection/collection.dart';

Node? getCellNode(Node tableNode, int col, int row) {
  return tableNode.children.firstWhereOrNull(
    (n) =>
        n.attributes[TableBlockKeys.colPosition] == col &&
        n.attributes[TableBlockKeys.rowPosition] == row,
  );
}
