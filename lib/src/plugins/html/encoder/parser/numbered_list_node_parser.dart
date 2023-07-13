import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/dom.dart' as dom;

import '../delta_html_encoder.dart';

class HtmlNumberedListNodeParser extends HtmlNodeParser {
  const HtmlNumberedListNodeParser();

  @override
  String get id => NumberedListBlockKeys.type;

  @override
  String transform(Node node) {
    assert(node.type == NumberedListBlockKeys.type);
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
