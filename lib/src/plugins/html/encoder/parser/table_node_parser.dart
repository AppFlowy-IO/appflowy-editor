import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:collection/collection.dart';
import 'package:html/dom.dart' as dom;

import '../../../../editor/block_component/table_block_component/util.dart';

class HtmlTableNodeParser extends HTMLNodeParser {
  const HtmlTableNodeParser();

  @override
  String get id => TableBlockKeys.type;

  @override
  String transformNodeToHTMLString(
    Node node, {
    required List<HTMLNodeParser> encodeParsers,
  }) {
    assert(node.type == TableBlockKeys.type);

    return toHTMLString(
      transformNodeToDomNodes(node, encodeParsers: encodeParsers),
    );
  }

  @override
  List<dom.Node> transformNodeToDomNodes(
    Node node, {
    required List<HTMLNodeParser> encodeParsers,
  }) {
    final int rowsLen = node.attributes[TableBlockKeys.rowsLen],
        colsLen = node.attributes[TableBlockKeys.colsLen];
    final List<dom.Node> domNodes = [];

    for (var i = 0; i < rowsLen; i++) {
      final List<dom.Node> nodes = [];
      for (var j = 0; j < colsLen; j++) {
        final Node cell = getCellNode(node, j, i)!;

        for (final childnode in cell.children) {
          HTMLNodeParser? parser = encodeParsers.firstWhereOrNull(
            (element) => element.id == childnode.type,
          );

          if (parser != null) {
            nodes.add(
              wrapChildrenNodesWithTagName(
                HTMLTags.tabledata,
                childNodes: parser.transformNodeToDomNodes(
                  childnode,
                  encodeParsers: encodeParsers,
                ),
              ),
            );
          }
        }
      }
      final rowelement =
          wrapChildrenNodesWithTagName(HTMLTags.tableRow, childNodes: nodes);

      domNodes.add(rowelement);
    }

    final element =
        wrapChildrenNodesWithTagName(HTMLTags.table, childNodes: domNodes);
    return [
      element,
    ];
  }
}
