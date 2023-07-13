import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/dom.dart' as dom;
import 'htmlparser.dart';
class HtmlImageNodeParser extends HtmlNodeParser {
  const HtmlImageNodeParser();

  @override
  String get id => ImageBlockKeys.type;

  @override
  String transform(Node node) {
    final List<dom.Node> result = [];
    final delta = node.delta;
    if (delta == null) {
      throw Exception('Delta is null');
    }

    final anchor = dom.Element.tag(HTMLTags.image);
    anchor.attributes["src"] = node.attributes[ImageBlockKeys.url];
    anchor.attributes["height"] = node.attributes[ImageBlockKeys.height];
    anchor.attributes["width"] = node.attributes[ImageBlockKeys.width];
    anchor.attributes["align"] = node.attributes[ImageBlockKeys.align];
    result.add(anchor);

    return toHTMLString(result);
  }

 
}
