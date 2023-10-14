import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/util.dart';

class TableNodeParser extends NodeParser {
  const TableNodeParser();

  @override
  String get id => 'table';

  @override
  String transform(Node node, DocumentMarkdownEncoder? encoder) {
    final int rowsLen = node.attributes['rowsLen'],
        colsLen = node.attributes['colsLen'];
    String result = '';

    for (var i = 0; i < rowsLen; i++) {
      for (var j = 0; j < colsLen; j++) {
        final Node cell = getCellNode(node, j, i)!;
        String cellStr = '|${documentToMarkdown(Document(root: cell))}';
        // markdown doesn't have literally empty table cell
        cellStr = cellStr == '|' ? '| ' : cellStr;

        result += j == colsLen - 1 ? '$cellStr|\n' : cellStr;
      }
    }
    result = result.substring(0, result.length - 1);

    String tableMark = '';
    for (var j = 0; j < colsLen; j++) {
      tableMark += j == colsLen - 1 ? '|-|' : '|-';
    }

    final List<String> lines = result.split('\n');
    lines.insert(1, tableMark);
    result = lines.join('\n');

    return node.next == null ? result : '$result\n';
  }
}
