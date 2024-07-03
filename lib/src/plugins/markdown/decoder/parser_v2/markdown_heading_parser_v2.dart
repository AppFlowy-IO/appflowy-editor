import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:markdown/markdown.dart' as md;

final _headingTags = ['h1', 'h2', 'h3', 'h4', 'h5', 'h6'];

class MarkdownHeadingParserV2 extends CustomMarkdownElementParser {
  const MarkdownHeadingParserV2();

  @override
  List<Node> transform(
    md.Node element,
    List<CustomMarkdownElementParser> parsers,
    MarkdownListType listType,
  ) {
    if (element is! md.Element) {
      return [];
    }

    if (!_headingTags.contains(element.tag)) {
      return [];
    }

    final level = _headingTags.indexOf(element.tag) + 1;

    final deltaDecoder = DeltaMarkdownDecoder();
    return [
      headingNode(
        level: level,
        delta: deltaDecoder.convertNodes(element.children),
      ),
    ];
  }
}
