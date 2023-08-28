import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/plugins/markdown/decoder/parser/custom_node_parser.dart';

class TestCustomNodeParser extends CustomNodeParser {
  final nodeRegex = RegExp(r'\[Custom Node\]\(.+?\)');
  @override
  Node? transform(String input) {
    if (nodeRegex.hasMatch(input)) {
      return Node(type: 'custom node');
    }
    return null;
  }
}
