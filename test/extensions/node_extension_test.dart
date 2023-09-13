import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('node_extension.dart', () {
    final selection = Selection(
      start: Position(path: [0]),
      end: Position(path: [1]),
    );

    test('inSelection', () {
      // I use an empty implementation instead of mock, because the mocked
      // version throws error trying to access the path.

      final subNodes = [
        Node(type: 'type'),
        Node(type: 'type'),
        Node(type: 'type'),
        Node(type: 'type'),
        Node(type: 'type'),
      ];

      final nodes = [
        Node(
          type: 'type',
          children: subNodes,
        ),
      ];

      final node = Node(
        type: 'type',
        children: nodes,
        attributes: {},
      );
      final result = node.inSelection(selection);
      expect(result, false);
    });

    test('inSelection w/ Reverse selection', () {
      final subNodes = [
        Node(
          type: 'type',
        ),
      ];

      final node = Node(
        type: 'type',
        children: subNodes,
      );

      final reverseSelection = Selection(
        start: Position(path: [1]),
        end: Position(path: [0]),
      );

      final result = node.inSelection(reverseSelection);
      expect(result, false);
    });
  });
}
