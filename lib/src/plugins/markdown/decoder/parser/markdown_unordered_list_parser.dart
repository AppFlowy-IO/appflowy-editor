import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:markdown/markdown.dart' as md;

class MarkdownUnorderedListParserV2 extends CustomMarkdownParser {
  const MarkdownUnorderedListParserV2();

  @override
  List<Node> transform(
    md.Node element,
    List<CustomMarkdownParser> parsers, {
    MarkdownListType listType = MarkdownListType.unknown,
    int? startNumber,
  }) {
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
