import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/plugins/markdown/decoder/parser_v2/markdown_parser_extension.dart';
import 'package:markdown/markdown.dart' as md;

class MarkdownUnorderedListParserV2 extends CustomMarkdownElementParser {
  const MarkdownUnorderedListParserV2();

  @override
  List<Node> transform(
    md.Node element,
    List<CustomMarkdownElementParser> parsers,
  ) {
    if (element is! md.Element) {
      return [];
    }

    if (element.tag != 'ul') {
      return [];
    }

    // flatten the list
    return parseElementChildren(element.children, parsers);
  }
}
