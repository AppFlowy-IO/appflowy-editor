import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/dom.dart' as dom;

class HtmlTextNodeParser extends HtmlNodeParser {
  const HtmlTextNodeParser();

  @override
  String get id => ParagraphBlockKeys.type;

  @override
  String transform(Node node, {required List<HtmlNodeParser> encodeParsers}) {
    return toHTMLString(htmlNodes(node, encodeParsers: encodeParsers));
  }

  @override
  List<dom.Node> htmlNodes(
    Node node, {
    required List<HtmlNodeParser> encodeParsers,
  }) {
    final delta = node.delta;
    final List<dom.Node> result = [];
    if (delta == null) {
      assert(false, 'Delta is null');
    }
    final convertedNodes = DeltaHtmlEncoder().convert(delta!);
    if (node.children.isNotEmpty) {
      convertedNodes.addAll(
        childrenNodes(node.children.toList(), encodeParsers: encodeParsers),
      );
    }

    const tagName = HTMLTags.paragraph;

    final element = insertText(tagName, childNodes: convertedNodes);
    result.add(element);
    return result;
  }
}
