import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/dom.dart' as dom;

class HtmlBulletedListNodeParser extends HtmlNodeParser {
  const HtmlBulletedListNodeParser();

  @override
  String get id => BulletedListBlockKeys.type;

  @override
  String transform(Node node, {required List<HtmlNodeParser> encodeParsers}) {
    assert(node.type == BulletedListBlockKeys.type);

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
    const tagName = HTMLTags.list;
    if (node.children.isNotEmpty) {
      convertedNodes.addAll(
        childrenNodes(node.children.toList(), encodeParsers: encodeParsers),
      );
    }
    final element = insertText(tagName, childNodes: convertedNodes);

    final stashListContainer = dom.Element.tag(
      HTMLTags.unorderedList,
    );
    stashListContainer.append(element);
    result.add(stashListContainer);
    return result;
  }
}
