import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/dom.dart' as dom;

import '../delta_html_encoder.dart';

class HtmlTodoListNodeParser extends HtmlNodeParser {
  const HtmlTodoListNodeParser();

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

    final elemntnode = dom.Element.html('<input type="checkbox" />');

    elemntnode.attributes['checked'] =
        node.attributes[TodoListBlockKeys.checked].toString();
    const tagName = HTMLTags.div;
    convertedNodes.add(elemntnode);
    final element = insertText(tagName, childNodes: convertedNodes);
    result.add(element);

    return toHTMLString(result);
  }
}
