import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/dom.dart' as dom;

import '../delta_html_encoder.dart';
import 'htmlparser.dart';
class HtmlNumberedListNodeParser extends HtmlNodeParser {
  const HtmlNumberedListNodeParser();

  @override
  String get id => 'numbered_list';

  @override
  String transform(Node node) {
    assert(node.type == 'numbered_list');
    final List<dom.Node> result = [];
    final delta = node.delta;
    if (delta == null) {
      throw Exception('Delta is null');
    }
    final convertedNodes = DeltaHtmlEncoder().convert(delta);
    const tagName = HTMLTags.list;

    final element = insertText(tagName, childNodes: convertedNodes);

    final stashListContainer = dom.Element.tag(
      HTMLTags.orderedList,
    );
    stashListContainer.append(element);
    result.add(stashListContainer);

    return toHTMLString(result);
  }

}
