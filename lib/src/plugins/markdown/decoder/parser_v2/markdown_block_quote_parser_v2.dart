import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:markdown/markdown.dart' as md;

class MarkdownBlockQuoteParserV2 extends CustomMarkdownElementParser {
  const MarkdownBlockQuoteParserV2();

  @override
  List<Node> transform(
    md.Node element,
    List<CustomMarkdownElementParser> parsers,
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
