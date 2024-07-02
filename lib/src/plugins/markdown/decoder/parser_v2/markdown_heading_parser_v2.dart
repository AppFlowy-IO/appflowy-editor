import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:markdown/markdown.dart' as md;

final _headingTags = ['h1', 'h2', 'h3', 'h4', 'h5', 'h6'];

class MarkdownHeadingParserV2 extends CustomMarkdownElementParser {
  const MarkdownHeadingParserV2();

  @override
  Node? transform(md.Node element) {
    if (element is! md.Element) {
      return null;
    }

    if (!_headingTags.contains(element.tag)) {
      return null;
    }

    final level = _headingTags.indexOf(el.tag) + 1;

    final deltaDecoder = DeltaMarkdownDecoder();
    return headingNode(
      level: level,
      delta: deltaDecoder.convert(element.textContent),
    );
  }
}
