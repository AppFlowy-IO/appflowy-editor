import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:markdown/markdown.dart' as md;

class MarkdownUnorderedListParserV2 extends CustomMarkdownElementParser {
  const MarkdownUnorderedListParserV2();

  @override
  List<Node> transform(
    md.Node element,
    List<CustomMarkdownElementParser> parsers,
    MarkdownListType listType,
  ) {
    if (element is! md.Element) {
      return [];
    }

    if (element.tag != 'ul') {
      return [];
    }

    // flatten the list
    return parseElementChildren(
      element.children,
      parsers,
      listType: MarkdownListType.unordered,
    );
  }
}
