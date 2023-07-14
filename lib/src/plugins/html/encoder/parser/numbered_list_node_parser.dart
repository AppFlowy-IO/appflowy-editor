import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/dom.dart' as dom;

class HtmlNumberedListNodeParser extends HtmlNodeParser {
  const HtmlNumberedListNodeParser();

  @override
  String get id => NumberedListBlockKeys.type;

  @override
  String transform(Node node, {required List<HtmlNodeParser> encodeParsers}) {
    assert(node.type == NumberedListBlockKeys.type);

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
      HTMLTags.orderedList,
    );
    stashListContainer.append(element);
    result.add(stashListContainer);
    return result;
  }
}
