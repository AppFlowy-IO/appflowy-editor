import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/dom.dart' as dom;

class HTMLNumberedListNodeParser extends HTMLNodeParser {
  const HTMLNumberedListNodeParser();

  @override
  String get id => NumberedListBlockKeys.type;

  @override
  String transformNodeToHTMLString(
    Node node, {
    required List<HTMLNodeParser> encodeParsers,
  }) {
    assert(node.type == NumberedListBlockKeys.type);

    final html = toHTMLString(
      transformNodeToDomNodes(node, encodeParsers: encodeParsers),
    );

    final number = node.attributes[NumberedListBlockKeys.number];
    final start = number != null ? '<ol start="$number">' : '<ol>';
    const end = '</ol>';
    if (node.previous?.type != NumberedListBlockKeys.type &&
        node.next?.type != NumberedListBlockKeys.type) {
      return '$start$html$end';
    } else if (node.previous?.type != NumberedListBlockKeys.type) {
      return '$start$html';
    } else if (node.next?.type != NumberedListBlockKeys.type) {
      return '$html$end';
    } else {
      return html;
    }
  }

  @override
  List<dom.Node> transformNodeToDomNodes(
    Node node, {
    required List<HTMLNodeParser> encodeParsers,
  }) {
    final delta = node.delta ?? Delta();
    final domNodes = deltaHTMLEncoder.convert(delta);
    domNodes.addAll(
      processChildrenNodes(node.children, encodeParsers: encodeParsers),
    );
    final element = wrapChildrenNodesWithTagName(
      HTMLTags.list,
      childNodes: domNodes,
    );
    return [element];
  }
}
