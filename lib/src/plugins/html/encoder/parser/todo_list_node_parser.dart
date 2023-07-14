import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/dom.dart' as dom;

class HtmlTodoListNodeParser extends HtmlNodeParser {
  const HtmlTodoListNodeParser();

  @override
  String get id => TodoListBlockKeys.type;

  @override
  String transform(Node node, {required List<HtmlNodeParser> encodeParsers}) {
    assert(node.type == TodoListBlockKeys.type);

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

    final elemntnode = dom.Element.html('<input type="checkbox" />');

    elemntnode.attributes['checked'] =
        node.attributes[TodoListBlockKeys.checked].toString();

    const tagName = HTMLTags.div;
    convertedNodes.add(elemntnode);
    if (node.children.isNotEmpty) {
      convertedNodes.addAll(
        childrenNodes(node.children.toList(), encodeParsers: encodeParsers),
      );
    }
    final element = insertText(tagName, childNodes: convertedNodes);
    result.add(element);
    return result;
  }
}
