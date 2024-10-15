import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:markdown/markdown.dart' as md;

class MarkdownParagraphParserV2 extends CustomMarkdownParser {
  const MarkdownParagraphParserV2();

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

    if (ec == null || ec.isEmpty) {
      // return empty paragraph node if there is no children
      return [
        paragraphNode(),
      ];
    }

    final nodes = <Node>[];
    for (final child in ec) {
      if (child is! md.Text) {
        nodes.addAll(parseElementChildren([child], parsers));
        continue;
      }
      final deltaDecoder = DeltaMarkdownDecoder();
      nodes.add(
        paragraphNode(
          delta: deltaDecoder.convertNodes([child]),
        ),
      );
    }
    return nodes;
  }
}
