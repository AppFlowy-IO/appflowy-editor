import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:markdown/markdown.dart' as md;

class MarkdownParagraphParserV2 extends CustomMarkdownElementParser {
  const MarkdownParagraphParserV2();

  @override
  List<Node> transform(
    md.Node element,
    List<CustomMarkdownElementParser> parsers,
  ) {
    if (element is! md.Element) {
      return [];
    }

    if (element.tag != 'p') {
      return [];
    }

    final deltaDecoder = DeltaMarkdownDecoder();
    return [
      paragraphNode(
        delta: deltaDecoder.convertNodes(element.children),
      ),
    ];
  }
}
