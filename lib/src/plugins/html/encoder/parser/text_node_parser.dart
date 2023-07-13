import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/dom.dart' as dom;

import '../delta_html_encoder.dart';

class HtmlTextNodeParser extends HtmlNodeParser {
  const HtmlTextNodeParser();

  @override
  String get id => ParagraphBlockKeys.type;

  @override
  String transform(Node node) {
    final delta = node.delta;
    final List<dom.Node> result = [];
    if (delta == null) {
      assert(false, 'Delta is null');
      return '';
    }
    final convertedNodes = DeltaHtmlEncoder().convert(delta);
    const tagName = HTMLTags.paragraph;

    final element = insertText(tagName, childNodes: convertedNodes);
    result.add(element);

    return toHTMLString(result);
  }
}
