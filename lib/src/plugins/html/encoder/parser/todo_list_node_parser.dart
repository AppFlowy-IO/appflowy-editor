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
    if (node.attributes[TodoListBlockKeys.checked] as bool? ?? false) {
      elementNode.attributes['checked'] = '';
    }
    domNodes.insert(0, elementNode);
    domNodes.addAll(
      processChildrenNodes(node.children, encodeParsers: encodeParsers),
    );

    final element =
        wrapChildrenNodesWithTagName(HTMLTags.div, childNodes: domNodes);
    return [element];
  }
}
