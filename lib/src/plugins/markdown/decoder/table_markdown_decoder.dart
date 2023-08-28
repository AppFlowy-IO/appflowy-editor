import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_node.dart';
import 'package:appflowy_editor/src/plugins/markdown/decoder/document_markdown_decoder.dart';

class TableMarkdownDecoder {
  Node convert(List<String> lines) {
    late List<List<Node>> columns;

    for (var i = 0; i < lines.length; i++) {
      // i = 1 is table mark (e.g "|-|-|")
      if (i == 1) {
        continue;
      }

      List<String> row = getCells(lines[i]);
      if (i == 0) {
        columns = List.generate(row.length, (_) => []);
      }

      if (row.length != columns.length) {
        break;
      }

      for (var i = 0; i < row.length; i++) {
        columns[i].add(DocumentMarkdownDecoder().convertLineToNode(row[i], []));
      }
    }

    return TableNode.fromList(columns).node;
  }

  static bool isTable(String line1, String line2) {
    if (!rowBeginAndEndCheck(line1) || !rowBeginAndEndCheck(line2)) {
      return false;
    }
    return getCells(line1).length ==
        getCells(line2, pat: r'\|([ -]+)\|').length;
  }
}

final rowBeginningRegex = RegExp(r'^ *\|');
final rowEndingRegex = RegExp(r'\| *$');

bool rowBeginAndEndCheck(String line) {
  return line.contains(rowBeginningRegex) && line.contains(rowEndingRegex);
}

List<String> getCells(String line, {String pat = r'\|(.+?)(?<!\\)\|'}) {
  List<String> cells = [];
  final regex = RegExp(pat);

  line = line.trim();
  while (line.contains(regex)) {
    String cell =
        regex.firstMatch(line)!.group(1)!.trim().replaceAll(r'\|', '|');
    cell = cell == '' ? ' ' : cell;
    cells.add(cell);

    line = line.replaceFirst(regex, '|');
  }

  return line == '|' ? cells : [];
}
