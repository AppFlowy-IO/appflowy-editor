import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/dom.dart' as dom;

class HTMLTextNodeParser extends HTMLNodeParser {
  const HTMLTextNodeParser();

  @override
  String get id => ParagraphBlockKeys.type;

  @override
  String transformNodeToHTMLString(
    Node node, {
    required List<HTMLNodeParser> encodeParsers,
  }) {
    return toHTMLString(
      transformNodeToDomNodes(node, encodeParsers: encodeParsers),
    );
  }

  @override
  List<dom.Node> transformNodeToDomNodes(
    Node node, {
    required List<HTMLNodeParser> encodeParsers,
  }) {
    final delta = node.delta ?? Delta();
    final domNodes = deltaHTMLEncoder.convert(delta);
    domNodes.addAll(
      processChildrenNodes(
        node.children.toList(),
        encodeParsers: encodeParsers,
      ),
    );
    if (domNodes.isEmpty) {
      return [dom.Element.tag(HTMLTags.br)];
    }
    final element =
        wrapChildrenNodesWithTagName(HTMLTags.paragraph, childNodes: domNodes);
    return [element];
  }
}
