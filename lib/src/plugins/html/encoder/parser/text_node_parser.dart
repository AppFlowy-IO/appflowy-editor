import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/dom.dart' as dom;

class HtmlTextNodeParser extends HTMLNodeParser {
  const HtmlTextNodeParser();

  @override
  String get id => ParagraphBlockKeys.type;

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
    final domNodes = deltaHTMLEncoder.convert(delta);
    domNodes.addAll(
      childrenNodes(node.children.toList(), encodeParsers: encodeParsers),
    );

    final element = insertText(HTMLTags.paragraph, childNodes: domNodes);
    return [element];
  }
}
