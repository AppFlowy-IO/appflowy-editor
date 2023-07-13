import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:html/dom.dart' as dom;

import '../delta_html_encoder.dart';
import 'htmlparser.dart';

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
    late String tagName;
    if (attribute[HeadingBlockKeys.level] == 1) {
      tagName = HTMLTags.h1;
    } else if (attribute[HeadingBlockKeys.level] == 2) {
      tagName = HTMLTags.h2;
    } else if (attribute[HeadingBlockKeys.level] == 3) {
      tagName = HTMLTags.h3;
    }

  final element = insertText(tagName, childNodes: convertedNodes);
    result.add(element);

    return toHTMLString(result);
  }


}
