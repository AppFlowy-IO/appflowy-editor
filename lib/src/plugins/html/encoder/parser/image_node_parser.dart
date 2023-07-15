import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/dom.dart' as dom;

class HtmlImageNodeParser extends HtmlNodeParser {
  const HtmlImageNodeParser();

  @override
  String get id => ImageBlockKeys.type;

  @override
  String transform(Node node, {required List<HtmlNodeParser> encodeParsers}) {
    return toHTMLString(htmlNodes(node, encodeParsers: encodeParsers));
  }

  @override
  List<dom.Node> htmlNodes(
    Node node, {
    required List<HtmlNodeParser> encodeParsers,
  }) {
    final List<dom.Node> result = [];

    final anchor = dom.Element.tag(HTMLTags.image);
    anchor.attributes["src"] = node.attributes[ImageBlockKeys.url];
    if (node.attributes[ImageBlockKeys.height] != null) {
      anchor.attributes["height"] = node.attributes[ImageBlockKeys.height];
    }
    if (node.attributes[ImageBlockKeys.width] != null) {
      anchor.attributes["width"] = node.attributes[ImageBlockKeys.width];
    }
    if (node.attributes[ImageBlockKeys.align] != null) {
      anchor.attributes["align"] = node.attributes[ImageBlockKeys.align];
    }
    result.add(anchor);

    if (node.children.isNotEmpty) {
      result.addAll(
        childrenNodes(node.children.toList(), encodeParsers: encodeParsers),
      );
    }
    return result;
  }
}
