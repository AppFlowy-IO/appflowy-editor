import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('divider_node_parser.dart', () {
    test('parser divider node', () {
      final node = Node(
        type: DividerBlockKeys.type,
      );

      final result = const DividerNodeParser().transform(node, null);
      expect(result, '---\n');
    });

    test('DividerNodeParser id getter', () {
      const imageNodeParser = DividerNodeParser();
      expect(imageNodeParser.id, 'divider');
    });
  });
}
