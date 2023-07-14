import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/dom.dart' as dom;

class HtmlQuoteNodeParser extends HtmlNodeParser {
  const HtmlQuoteNodeParser();

  @override
  String get id => QuoteBlockKeys.type;

  @override
  String transform(Node node, {required List<HtmlNodeParser> encodeParsers}) {
    assert(node.type == QuoteBlockKeys.type);

    return toHTMLString(htmlNodes(node, encodeParsers: encodeParsers));
  }

  @override
  List<dom.Node> htmlNodes(
    Node node, {
    required List<HtmlNodeParser> encodeParsers,
  }) {
    final List<dom.Node> result = [];
    final delta = node.delta;
    if (delta == null) {
      throw Exception('Delta is null');
    }
    final convertedNodes = DeltaHtmlEncoder().convert(delta);
    if (node.children.isNotEmpty) {
      convertedNodes.addAll(
        childrenNodes(node.children.toList(), encodeParsers: encodeParsers),
      );
    }
    const tagName = HTMLTags.blockQuote;

    final element = insertText(tagName, childNodes: convertedNodes);
    result.add(element);
    return result;
  }
}
