import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/plugins/markdown/decoder/parser_v2/markdown_parser_extension.dart';
import 'package:markdown/markdown.dart' as md;

class MarkdownDividerParserV2 extends CustomMarkdownElementParser {
  const MarkdownDividerParserV2();

  @override
  List<Node> transform(
    md.Node element,
    List<CustomMarkdownElementParser> parsers,
    MarkdownListType listType,
  ) {
    if (element is! md.Element) {
      return [];
    }

    if (element.tag != 'hr') {
      return [];
    }

    return [
      dividerNode(),
    ];
  }
}