import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:markdown/markdown.dart' as md;

class MarkdownTableListParserV2 extends CustomMarkdownParser {
  const MarkdownTableListParserV2();

  @override
  List<Node> transform(
    md.Node element,
    List<CustomMarkdownParser> parsers, {
    MarkdownListType listType = MarkdownListType.unknown,
    int? startNumber,
  }) {
    if (element is! md.Element) {
      return [];
    }

    if (element.tag != 'table') {
      return [];
    }

    final ec = element.children;
    if (ec == null || ec.isEmpty) {
      return [];
    }

    final List<List<Node>> cells = [];

    final th = ec
        .whereType<md.Element>()
        .where((e) => e.tag == 'thead')
        .firstOrNull
        ?.children
        ?.whereType<md.Element>()
        .where((e) => e.tag == 'tr')
        .expand((e) => e.children?.whereType<md.Element>().toList() ?? [])
        .where((e) => e.tag == 'th')
        .toList();

    final td = ec
        .whereType<md.Element>()
        .where((e) => e.tag == 'tbody')
        .firstOrNull
        ?.children
        ?.whereType<md.Element>()
        .where((e) => e.tag == 'tr')
        .expand((e) => e.children?.whereType<md.Element>().toList() ?? [])
        .where((e) => e.tag == 'td')
        .toList();

    if (th == null || td == null || th.isEmpty || td.isEmpty) {
      return [];
    }

    for (var i = 0; i < th.length; i++) {
      final List<Node> row = [];

      row.add(
        paragraphNode(
          delta: DeltaMarkdownDecoder().convertNodes(th[i].children),
        ),
      );

      for (var j = i; j < td.length; j += th.length) {
        row.add(
          paragraphNode(
            delta: DeltaMarkdownDecoder().convertNodes(td[j].children),
          ),
        );
      }

      cells.add(row);
    }

    final tableNode = TableNode.fromList(cells);

    return [
      tableNode.node,
    ];
  }
}
