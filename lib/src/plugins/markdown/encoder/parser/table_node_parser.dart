import 'package:appflowy_editor/src/core/document/document.dart';
import 'package:appflowy_editor/src/core/document/node.dart';
import 'package:appflowy_editor/src/plugins/markdown/encoder/parser/node_parser.dart';
import 'package:appflowy_editor/src/plugins/markdown/encoder/document_markdown_encoder.dart';
import 'package:appflowy_editor/src/plugins/markdown/encoder/parser/text_node_parser.dart';
import 'package:appflowy_editor/src/render/table/util.dart';

class TableNodeParser extends NodeParser {
  const TableNodeParser();

  @override
  String get id => 'table';

  @override
  String transform(Node node) {
    final dme = DocumentMarkdownEncoder(
      parsers: [const TextNodeParser()],
    );
    final int rowsLen = node.attributes['rowsLen'],
        colsLen = node.attributes['colsLen'];
    String result = '';

    for (var i = 0; i < rowsLen; i++) {
      if (i == 1) {
        for (var j = 0; j < colsLen; j++) {
          result += j == colsLen - 1 ? '|-|\n' : '|-';
        }
      }

      for (var j = 0; j < colsLen; j++) {
        var cell = getCellNode(node, j, i)!;
        result += '|${dme.convert(Document(root: cell))}';
        result += j == colsLen - 1 ? '|\n' : '';
      }
    }

    return result;
  }
}
