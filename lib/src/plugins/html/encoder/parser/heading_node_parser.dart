import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/dom.dart' as dom;

class HtmlHeadingNodeParser extends HtmlNodeParser {
  const HtmlHeadingNodeParser();

  @override
  String get id => HeadingBlockKeys.type;

  @override
  String transform(Node node) {
    final delta = node.delta;
    final attribute = node.attributes;
    final List<dom.Node> result = [];
    if (delta == null) {
      assert(false, 'Delta is null');
      return '';
    }
    final convertedNodes = DeltaHtmlEncoder().convert(delta);
    String tagName = "h${attribute[HeadingBlockKeys.level]}";

    final element = insertText(tagName, childNodes: convertedNodes);
    result.add(element);

    return toHTMLString(result);
  }
}
