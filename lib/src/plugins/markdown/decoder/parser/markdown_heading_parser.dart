import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/plugins/markdown/decoder/parser/custom_markdown_node_parser.dart';

class MarkdownHeadingParser extends CustomMarkdownNodeParser {
  const MarkdownHeadingParser();

  @override
  Node? transform(DeltaMarkdownDecoder decoder, String input) {
    final match = RegExp(r'^(#{1,6})\s(.*)').firstMatch(input);
    if (match == null) {
      return null;
    }

    final level = match.group(1)!.length;
    final text = match.group(2)!;

    return headingNode(
      level: level,
      delta: decoder.convert(text),
    );
  }
}
