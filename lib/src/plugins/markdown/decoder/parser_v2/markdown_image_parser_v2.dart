import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/plugins/markdown/decoder/parser_v2/markdown_parser_extension.dart';
import 'package:markdown/markdown.dart' as md;

class MarkdownImageParserV2 extends CustomMarkdownElementParser {
  const MarkdownImageParserV2();

  @override
  List<Node> transform(
    md.Node element,
    List<CustomMarkdownElementParser> parsers,
    MarkdownListType listType,
  ) {
    if (element is! md.Element) {
      return [];
    }

    if (element.tag != 'p') {
      return [];
    }

    if (element.children?.length != 1 ||
        element.children?.first is! md.Element) {
      return [];
    }
    final ec = element.children?.first as md.Element;
    if (ec.tag != 'img' || ec.attributes['src'] == null) {
      return [];
    }

    return [
      imageNode(url: ec.attributes['src']!),
    ];
  }
}
