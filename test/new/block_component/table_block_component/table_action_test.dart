import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_node.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/util.dart';
import '../../infra/testable_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('table_action.dart', () {
    testWidgets('remove column', (tester) async {
      var tableNode = TableNode.fromList([
        ['1', '2'],
        ['3', '4']
      ]);
      final editor = tester.editor..addNode(tableNode.node);

      await editor.startTesting();
      await tester.pumpAndSettle();

      final transaction = editor.editorState.transaction;
      TableActions.delete(tableNode.node, 0, transaction, TableDirection.col);
      editor.editorState.apply(transaction);
      await tester.pump(const Duration(milliseconds: 100));
      tableNode = TableNode(node: tableNode.node);

      expect(tableNode.colsLen, 1);
      expect(
        tableNode.getCell(0, 0).children.first.toJson(),
        {
          "type": "paragraph",
          "data": {
            "delta": [
              {"insert": "3"}
            ]
          }
        },
      );
      await editor.dispose();
    });

    testWidgets('remove row', (tester) async {
      var tableNode = TableNode.fromList([
        ['1', '2'],
        ['3', '4']
      ]);
      final editor = tester.editor..addNode(tableNode.node);

      await editor.startTesting();
      await tester.pumpAndSettle();

      final transaction = editor.editorState.transaction;
      TableActions.delete(tableNode.node, 0, transaction, TableDirection.row);
      editor.editorState.apply(transaction);
      await tester.pump(const Duration(milliseconds: 100));
      tableNode = TableNode(node: tableNode.node);

      expect(tableNode.rowsLen, 1);
      expect(
        tableNode.getCell(0, 0).children.first.toJson(),
        {
          "type": "paragraph",
          "data": {
            "delta": [
              {"insert": "2"}
            ]
          }
        },
      );
      await editor.dispose();
    });

    testWidgets('duplicate column', (tester) async {
      var tableNode = TableNode.fromList([
        ['1', '2'],
        ['3', '4']
      ]);
      final editor = tester.editor..addNode(tableNode.node);

      await editor.startTesting();
      await tester.pumpAndSettle();

      final transaction = editor.editorState.transaction;
      TableActions.duplicate(
        tableNode.node,
        0,
        transaction,
        TableDirection.col,
      );
      editor.editorState.apply(transaction);
      await tester.pump(const Duration(milliseconds: 100));
      tableNode = TableNode(node: tableNode.node);

      expect(tableNode.colsLen, 3);
      for (var i = 0; i < tableNode.rowsLen; i++) {
        expect(
          getCellNode(tableNode.node, 0, i)!.children.first.toJson(),
          getCellNode(tableNode.node, 1, i)!.children.first.toJson(),
        );
      }
      await editor.dispose();
    });

    testWidgets('duplicate row', (tester) async {
      var tableNode = TableNode.fromList([
        ['1', '2'],
        ['3', '4']
      ]);
      final editor = tester.editor..addNode(tableNode.node);

      await editor.startTesting();
      await tester.pumpAndSettle();

      final transaction = editor.editorState.transaction;
      TableActions.duplicate(
        tableNode.node,
        0,
        transaction,
        TableDirection.row,
      );
      editor.editorState.apply(transaction);
      await tester.pump(const Duration(milliseconds: 100));
      tableNode = TableNode(node: tableNode.node);

      expect(tableNode.rowsLen, 3);
      for (var i = 0; i < tableNode.colsLen; i++) {
        expect(
          getCellNode(tableNode.node, i, 0)!.children.first.toJson(),
          getCellNode(tableNode.node, i, 1)!.children.first.toJson(),
        );
      }
      await editor.dispose();
    });
  });
}
