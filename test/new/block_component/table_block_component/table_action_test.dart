import 'package:flutter/material.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_node.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/util.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../infra/testable_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('table_action.dart', () {
    testWidgets('remove column', (tester) async {
      var tableNode = TableNode.fromList([
        ['1', '2'],
        ['3', '4'],
      ]);
      final editor = tester.editor..addNode(tableNode.node);

      await editor.startTesting();
      await tester.pumpAndSettle();

      TableActions.delete(
        tableNode.node,
        0,
        editor.editorState,
        TableDirection.col,
      );
      await tester.pump(const Duration(milliseconds: 100));
      tableNode = TableNode(node: tableNode.node);

      expect(tableNode.colsLen, 1);
      expect(
        tableNode.getCell(0, 0).children.first.toJson(),
        {
          "type": "paragraph",
          "data": {
            "delta": [
              {"insert": "3"},
            ],
          },
        },
      );
      await editor.dispose();
    });

    testWidgets('remove row', (tester) async {
      var tableNode = TableNode.fromList([
        ['1', '2'],
        ['3', '4'],
      ]);
      final editor = tester.editor..addNode(tableNode.node);

      await editor.startTesting();
      await tester.pumpAndSettle();

      TableActions.delete(
        tableNode.node,
        0,
        editor.editorState,
        TableDirection.row,
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
      tableNode = TableNode(node: tableNode.node);

      expect(tableNode.rowsLen, 1);
      expect(
        tableNode.getCell(0, 0).children.first.toJson(),
        {
          "type": "paragraph",
          "data": {
            "delta": [
              {"insert": "2"},
            ],
          },
        },
      );

      await editor.dispose();
    });

    testWidgets('remove the last column', (tester) async {
      var tableNode = TableNode.fromList([
        ['1', '2'],
      ]);
      final editor = tester.editor..addNode(tableNode.node);

      await editor.startTesting();
      await tester.pumpAndSettle();

      TableActions.delete(
        tableNode.node,
        0,
        editor.editorState,
        TableDirection.col,
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      expect(tester.editor.document.isEmpty, isTrue);
      await editor.dispose();
    });

    testWidgets('remove the last row', (tester) async {
      var tableNode = TableNode.fromList([
        ['1'],
        ['3'],
      ]);
      final editor = tester.editor..addNode(tableNode.node);

      await editor.startTesting();
      await tester.pumpAndSettle();

      TableActions.delete(
        tableNode.node,
        0,
        editor.editorState,
        TableDirection.row,
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      expect(tester.editor.document.isEmpty, isTrue);
      await editor.dispose();
    });

    testWidgets('duplicate column', (tester) async {
      var tableNode = TableNode.fromList([
        ['1', '2'],
        ['3', '4'],
      ]);
      final editor = tester.editor..addNode(tableNode.node);

      await editor.startTesting();
      await tester.pumpAndSettle();

      TableActions.duplicate(
        tableNode.node,
        0,
        editor.editorState,
        TableDirection.col,
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
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
        ['3', '4'],
      ]);
      final editor = tester.editor..addNode(tableNode.node);

      await editor.startTesting();
      await tester.pumpAndSettle();

      TableActions.duplicate(
        tableNode.node,
        0,
        editor.editorState,
        TableDirection.row,
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
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

    testWidgets('add column', (tester) async {
      var tableNode = TableNode.fromList([
        ['', ''],
        ['', ''],
      ]);
      final editor = tester.editor..addNode(tableNode.node);

      await editor.startTesting();
      await tester.pumpAndSettle();

      TableActions.add(
        tableNode.node,
        2,
        editor.editorState,
        TableDirection.col,
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      tableNode = TableNode(node: tableNode.node);

      expect(tableNode.colsLen, 3);
      expect(
        tableNode.getCell(2, 1).children.first.toJson(),
        {
          "type": "paragraph",
          "data": {"delta": []},
        },
      );
      expect(tableNode.getColWidth(2), tableNode.config.colDefaultWidth);
      await editor.dispose();
    });

    testWidgets('add row', (tester) async {
      var tableNode = TableNode.fromList([
        ['', ''],
        ['', ''],
      ]);
      final editor = tester.editor..addNode(tableNode.node);

      await editor.startTesting();
      await tester.pumpAndSettle();

      TableActions.add(
        tableNode.node,
        2,
        editor.editorState,
        TableDirection.row,
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      tableNode = TableNode(node: tableNode.node);

      expect(tableNode.rowsLen, 3);
      expect(
        tableNode.getCell(0, 2).children.first.toJson(),
        {
          "type": "paragraph",
          "data": {"delta": []},
        },
      );

      var cell12 = getCellNode(tableNode.node, 1, 2)!;
      expect(tableNode.getRowHeight(2), cell12.children.first.rect.height + 8);
      await editor.dispose();
    });

    testWidgets('set row bg color', (tester) async {
      var tableNode = TableNode.fromList([
        ['', ''],
        ['', ''],
      ]);
      final editor = tester.editor..addNode(tableNode.node);

      await editor.startTesting();
      await tester.pumpAndSettle();

      final color = Colors.green.toHex();
      TableActions.setBgColor(
        tableNode.node,
        0,
        editor.editorState,
        color,
        TableDirection.row,
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      for (var i = 0; i < 2; i++) {
        expect(
          tableNode
              .getCell(i, 0)
              .attributes[TableCellBlockKeys.rowBackgroundColor],
          color,
        );
      }
      await editor.dispose();
    });

    testWidgets('add column respect row bg color', (tester) async {
      var tableNode = TableNode.fromList([
        ['', ''],
        ['', ''],
      ]);
      final editor = tester.editor..addNode(tableNode.node);

      await editor.startTesting();
      await tester.pumpAndSettle();

      final color = Colors.green.toHex();
      TableActions.setBgColor(
        tableNode.node,
        0,
        editor.editorState,
        color,
        TableDirection.row,
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      TableActions.add(
        tableNode.node,
        2,
        editor.editorState,
        TableDirection.col,
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      tableNode = TableNode(node: tableNode.node);

      expect(tableNode.colsLen, 3);
      expect(
        tableNode
            .getCell(2, 0)
            .attributes[TableCellBlockKeys.rowBackgroundColor],
        color,
      );
      await editor.dispose();
    });

    testWidgets('add row respect column bg color', (tester) async {
      var tableNode = TableNode.fromList([
        ['', ''],
        ['', ''],
      ]);
      final editor = tester.editor..addNode(tableNode.node);

      await editor.startTesting();
      await tester.pumpAndSettle();

      final color = Colors.green.toHex();
      TableActions.setBgColor(
        tableNode.node,
        0,
        editor.editorState,
        color,
        TableDirection.col,
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      TableActions.add(
        tableNode.node,
        2,
        editor.editorState,
        TableDirection.row,
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 1000));
      tableNode = TableNode(node: tableNode.node);

      expect(tableNode.rowsLen, 3);
      expect(
        tableNode
            .getCell(0, 2)
            .attributes[TableCellBlockKeys.colBackgroundColor],
        color,
      );
    });
  });
}
