import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/plugins/markdown/decoder/parser_v2/markdown_parser_extension.dart';
import 'package:markdown/markdown.dart' as md;

class MarkdownBlockQuoteParserV2 extends CustomMarkdownElementParser {
  const MarkdownBlockQuoteParserV2();

  @override
  List<Node> transform(
    md.Node element,
    List<CustomMarkdownElementParser> parsers,
    MarkdownListType listType,
  ) {
    if (element is! md.Element) {
      return [];
    }

    if (element.tag != 'blockquote') {
      return [];
    }

    final deltaDecoder = DeltaMarkdownDecoder();
    return [
      quoteNode(
        delta: deltaDecoder.convertNodes(element.children),
      ),
    ];
  }
}