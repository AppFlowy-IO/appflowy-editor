import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/dom.dart' as dom;

import '../delta_html_encoder.dart';

class HtmlQuoteNodeParser extends HtmlNodeParser {
  const HtmlQuoteNodeParser();

  @override
  String get id => QuoteBlockKeys.type;

  @override
  String transform(Node node) {
    assert(node.type == QuoteBlockKeys.type);
    final List<dom.Node> result = [];
    final delta = node.delta;
    if (delta == null) {
      throw Exception('Delta is null');
    }
    final convertedNodes = DeltaHtmlEncoder().convert(delta);
    const tagName = HTMLTags.blockQuote;

    final element = insertText(tagName, childNodes: convertedNodes);
    result.add(element);

    return toHTMLString(result);
  }
}
