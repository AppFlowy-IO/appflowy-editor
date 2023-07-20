import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/dom.dart' as dom;

class HTMLTodoListNodeParser extends HTMLNodeParser {
  const HTMLTodoListNodeParser();

  @override
  String get id => TodoListBlockKeys.type;

  @override
  String transformNodeToHTMLString(
    Node node, {
    required List<HTMLNodeParser> encodeParsers,
  }) {
    assert(node.type == TodoListBlockKeys.type);

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
    final elementNode = dom.Element.html('<input type="checkbox" />');
    elementNode.attributes['checked'] =
        node.attributes[TodoListBlockKeys.checked].toString();
    domNodes.add(elementNode);
    domNodes.addAll(
      processChildrenNodes(node.children, encodeParsers: encodeParsers),
    );

    final element =
        wrapChildrenNodesWithTagName(HTMLTags.div, childNodes: domNodes);
    return [element];
  }
}
