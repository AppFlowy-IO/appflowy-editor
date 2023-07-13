import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/dom.dart' as dom;

import '../delta_html_encoder.dart';
import 'htmlparser.dart';

class HtmlBulletedListNodeParser extends HtmlNodeParser {
  const HtmlBulletedListNodeParser();

  @override
  String get id => BulletedListBlockKeys.type;

  @override
  String transform(Node node) {
    assert(node.type == BulletedListBlockKeys.type);
    final List<dom.Node> result = [];
    final delta = node.delta;
    if (delta == null) {
      throw Exception('Delta is null');
    }
    final convertedNodes = DeltaHtmlEncoder().convert(delta);
    const tagName = HTMLTags.list;

    final element = _insertText(tagName, childNodes: convertedNodes);

    final stashListContainer = dom.Element.tag(
      HTMLTags.unorderedList,
    );
    stashListContainer.append(element);
    result.add(stashListContainer);

    return toHTMLString(result);
  }

  dom.Element _insertText(
    String tagName, {
    required List<dom.Node> childNodes,
  }) {
    final p = dom.Element.tag(tagName);
    for (final node in childNodes) {
      p.append(node);
    }
    return p;
  }

  String toHTMLString(List<dom.Node> nodes) {
    final elements = nodes;
    final copyString = elements.fold<String>(
      '',
      (previousValue, element) => previousValue + stringify(element),
    );
    return copyString.replaceAll("\n", "");
  }
}
