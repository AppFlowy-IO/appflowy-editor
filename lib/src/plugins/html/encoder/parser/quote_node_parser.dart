import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/dom.dart' as dom;

class HTMLQuoteNodeParser extends HTMLNodeParser {
  const HTMLQuoteNodeParser();

  @override
  String get id => QuoteBlockKeys.type;

  @override
  String transformNodeToHTMLString(
    Node node, {
    required List<HTMLNodeParser> encodeParsers,
  }) {
    assert(node.type == QuoteBlockKeys.type);

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
      processChildrenNodes(node.children, encodeParsers: encodeParsers),
    );

    final element =
        wrapChildrenNodesWithTagName(HTMLTags.blockQuote, childNodes: domNodes);
    return [element];
  }
}
