import 'package:appflowy_editor/src/plugins/markdown/encoder/parser/table_node_parser.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_node.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('table_node_parser.dart', () {
    test('parser table node', () {
      final node = TableNode.fromList([
        ['a'],
        ['b'],
      ]).node;

      final result = const TableNodeParser().transform(node);
      expect(result, '|a|b|\n|-|-|');
    });

    test('parser table node empty cells', () {
      final node = TableNode.fromList([
        [''],
        [''],
      ]).node;

      final result = const TableNodeParser().transform(node);
      expect(result, '| | |\n|-|-|');
    });
  });
}
