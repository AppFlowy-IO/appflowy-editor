import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/dom.dart' as dom;

class HTMLHeadingNodeParser extends HTMLNodeParser {
  const HTMLHeadingNodeParser();

  @override
  String get id => HeadingBlockKeys.type;

  @override
  String transformNodeToHTMLString(
    Node node, {
    required List<HTMLNodeParser> encodeParsers,
  }) {
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
    final convertedNodes = deltaHTMLEncoder.convert(delta);
    convertedNodes.addAll(
      processChildrenNodes(node.children, encodeParsers: encodeParsers),
    );
    final tagName = 'h${node.attributes[HeadingBlockKeys.level]}';
    final element =
        wrapChildrenNodesWithTagName(tagName, childNodes: convertedNodes);
    return [element];
  }
}
