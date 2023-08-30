import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_node.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/util.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../infra/testable_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('table_view.dart', () {
    // TODO(zoli)
    // testWidgets('resize column', (tester) async {});

    testWidgets('row height changing base on cell height', (tester) async {
      final tableNode = TableNode.fromList([
        ['', ''],
        ['', '']
      ]);
      final editor = tester.editor..addNode(tableNode.node);

      await editor.startTesting();
      await tester.pumpAndSettle();

      var row0beforeHeight = tableNode.getRowHeight(0);
      var row1beforeHeight = tableNode.getRowHeight(1);
      expect(row0beforeHeight == row1beforeHeight, true);

      var cell10 = getCellNode(tableNode.node, 1, 0)!;
      await editor.updateSelection(
        Selection.single(
          path: cell10.childAtIndexOrNull(0)!.path,
          startOffset: 0,
        ),
      );
      await editor.ime.insertText('aaaaaaaaa');

      final transaction = editor.editorState.transaction;
      tableNode.updateRowHeight(0, transaction);
      await editor.editorState.apply(transaction);

      expect(tableNode.getRowHeight(0) != row0beforeHeight, true);
      expect(tableNode.getRowHeight(0), cell10.children.first.rect.height + 8);
      expect(tableNode.getRowHeight(1), row1beforeHeight);
      expect(tableNode.getRowHeight(1) < tableNode.getRowHeight(0), true);
      await editor.dispose();
    });

    testWidgets('row height changing base on column width', (tester) async {
      final tableNode = TableNode.fromList([
        ['', ''],
        ['', '']
      ]);
      final editor = tester.editor..addNode(tableNode.node);

      await editor.startTesting();
      await tester.pumpAndSettle();

      var row0beforeHeight = tableNode.getRowHeight(0);
      var row1beforeHeight = tableNode.getRowHeight(1);
      expect(row0beforeHeight == row1beforeHeight, true);

      var cell10 = getCellNode(tableNode.node, 1, 0)!;
      await editor.updateSelection(
        Selection.single(
          path: cell10.childAtIndexOrNull(0)!.path,
          startOffset: 0,
        ),
      );
      await editor.ime.insertText('aaaaaaaaa');

      Transaction transaction = editor.editorState.transaction;
      tableNode.updateRowHeight(0, transaction);
      await editor.editorState.apply(transaction);

      expect(tableNode.getRowHeight(0) != row0beforeHeight, true);
      expect(tableNode.getRowHeight(0), cell10.children.first.rect.height + 8);

      transaction = editor.editorState.transaction;
      tableNode.setColWidth(1, 302.5, transaction);
      await editor.editorState.apply(transaction);

      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      expect(tableNode.getRowHeight(0), row0beforeHeight);
      await editor.dispose();
    });

    testWidgets('add column', (tester) async {
      var tableNode = TableNode.fromList([
        ['', ''],
        ['', '']
      ]);
      final editor = tester.editor..addNode(tableNode.node);

      await editor.startTesting();
      await tester.pumpAndSettle();

      final transaction = editor.editorState.transaction;
      TableActions.add(tableNode.node, 2, transaction, TableDirection.col);
      await editor.editorState.apply(transaction);
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      tableNode = TableNode(node: tableNode.node);

      expect(tableNode.colsLen, 3);
      expect(
        tableNode.getCell(2, 1).children.first.toJson(),
        {
          "type": "paragraph",
          "data": {"delta": []}
        },
      );
      expect(tableNode.getColWidth(2), tableNode.config.colDefaultWidth);
      await editor.dispose();
    });

    testWidgets('add row', (tester) async {
      var tableNode = TableNode.fromList([
        ['', ''],
        ['', '']
      ]);
      final editor = tester.editor..addNode(tableNode.node);

      await editor.startTesting();
      await tester.pumpAndSettle();

      final transaction = editor.editorState.transaction;
      TableActions.add(tableNode.node, 2, transaction, TableDirection.row);
      await editor.editorState.apply(transaction);
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      tableNode = TableNode(node: tableNode.node);

      expect(tableNode.rowsLen, 3);
      expect(
        tableNode.getCell(0, 2).children.first.toJson(),
        {
          "type": "paragraph",
          "data": {"delta": []}
        },
      );

      var cell12 = getCellNode(tableNode.node, 1, 2)!;
      expect(tableNode.getRowHeight(2), cell12.children.first.rect.height + 8);
      await editor.dispose();
    });
  });
}
