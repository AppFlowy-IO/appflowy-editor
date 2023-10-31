import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/dom.dart' as dom;

class HTMLImageNodeParser extends HTMLNodeParser {
  const HTMLImageNodeParser();

  @override
  String get id => ImageBlockKeys.type;

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
    final anchor = dom.Element.tag(HTMLTags.image);
    anchor.attributes['src'] = node.attributes[ImageBlockKeys.url];

    final height = node.attributes[ImageBlockKeys.height];
    if (height != null) {
      anchor.attributes['height'] = height.toString();
    }

    final width = node.attributes[ImageBlockKeys.width];
    if (width != null) {
      anchor.attributes['width'] = width.toString();
    }

    final align = node.attributes[ImageBlockKeys.align];
    if (align != null) {
      anchor.attributes['align'] = align;
    }

    return [
      anchor,
      ...processChildrenNodes(
        node.children.toList(),
        encodeParsers: encodeParsers,
      ),
    ];
  }
}
