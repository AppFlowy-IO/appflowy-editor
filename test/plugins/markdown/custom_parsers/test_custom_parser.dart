import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/plugins/markdown/decoder/parser/custom_markdown_node_parser.dart';

class TestCustomNodeParser extends CustomMarkdownNodeParser {
  final nodeRegex = RegExp(r'\[Custom Node\]\(.+?\)');
  @override
  Node? transform(DeltaMarkdownDecoder decoder, String input) {
    if (nodeRegex.hasMatch(input)) {
      return Node(type: 'custom node');
    }
    return null;
  }
}
