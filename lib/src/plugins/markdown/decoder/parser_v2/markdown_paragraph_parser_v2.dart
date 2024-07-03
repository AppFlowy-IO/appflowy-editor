import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:markdown/markdown.dart' as md;

class MarkdownParagraphParserV2 extends CustomMarkdownElementParser {
  const MarkdownParagraphParserV2();

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

    // exclude the img tag
    final ec = element.children;
    if (ec != null && ec.length == 1 && ec.first is md.Element) {
      final e = ec.first as md.Element;
      if (e.tag == 'img') {
        return [];
      }
    }

    final deltaDecoder = DeltaMarkdownDecoder();
    return [
      paragraphNode(
        delta: deltaDecoder.convertNodes(element.children),
      ),
    ];
  }
}
