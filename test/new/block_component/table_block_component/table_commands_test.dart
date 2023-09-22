import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_node.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/util.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../infra/testable_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('table_shortcut_event.dart', () {
    testWidgets('enter key on middle cells', (tester) async {
      final tableNode = TableNode.fromList([
        ['', ''],
        ['', ''],
      ]);
      final editor = tester.editor..addNode(tableNode.node);

      await editor.startTesting();
      await tester.pumpAndSettle();

      var cell00 = getCellNode(tableNode.node, 0, 0)!;

      await editor.updateSelection(
        Selection.single(
          path: cell00.childAtIndexOrNull(0)!.path,
          startOffset: 0,
        ),
      );
      await simulateKeyDownEvent(LogicalKeyboardKey.enter);

      var selection = editor.selection!;
      var cell01 = getCellNode(tableNode.node, 0, 1)!;

      expect(selection.isCollapsed, true);
      expect(selection.start.path, cell01.childAtIndexOrNull(0)!.path);
      expect(selection.start.offset, 0);
      await editor.dispose();
    });

    testWidgets('enter key on last cell', (tester) async {
      final tableNode = TableNode.fromList([
        ['', ''],
        ['', ''],
      ]);
      final editor = tester.editor..addNode(tableNode.node);

      await editor.startTesting();
      await tester.pumpAndSettle();

      var cell11 = getCellNode(tableNode.node, 1, 1)!;

      await editor.updateSelection(
        Selection.single(
          path: cell11.childAtIndexOrNull(0)!.path,
          startOffset: 0,
        ),
      );
      await simulateKeyDownEvent(LogicalKeyboardKey.enter);

      var selection = editor.selection!;

      expect(selection.isCollapsed, true);
      expect(selection.start.path, editor.nodeAtPath([1])!.path);
      expect(selection.start.offset, 0);
      expect(editor.documentRootLen, 2);
      await editor.dispose();
    });

    testWidgets('backspace on beginning of cell', (tester) async {
      final tableNode = TableNode.fromList([
        ['', ''],
        ['', ''],
      ]);
      final editor = tester.editor..addNode(tableNode.node);

      await editor.startTesting();
      await tester.pumpAndSettle();

      var cell10 = getCellNode(tableNode.node, 1, 0)!;

      await editor.updateSelection(
        Selection.single(
          path: cell10.childAtIndexOrNull(0)!.path,
          startOffset: 0,
        ),
      );
      await simulateKeyDownEvent(LogicalKeyboardKey.backspace);

      var selection = editor.selection!;

      expect(selection.isCollapsed, true);
      expect(selection.start.path, cell10.childAtIndexOrNull(0)!.path);
      expect(selection.start.offset, 0);
      await editor.dispose();
    });

    testWidgets('backspace on multiple cell selection', (tester) async {
      // final tableNode = TableNode.fromList([
      //   ['ab', 'cd'],
      //   ['ef', 'hi']
      // ]);
      // final editor = tester.editor..addNode(tableNode.node);

      // await editor.startTesting();
      // await tester.pumpAndSettle();

      // var cell11 = getCellNode(tableNode.node, 1, 1)!;
      // var cell10 = getCellNode(tableNode.node, 1, 0)!;

      // await editor.updateSelection(
      //   Selection(
      //     start: Position(
      //       path: cell11.childAtIndexOrNull(0)!.path,
      //       offset: 1,
      //     ),
      //     end: Position(
      //       path: cell10.childAtIndexOrNull(0)!.path,
      //       offset: 1,
      //     ),
      //   ),
      // );
      // await simulateKeyDownEvent(LogicalKeyboardKey.backspace);

      // var selection = editor.selection!;

      // expect(selection.isCollapsed, true);
      // expect(selection.start.path, cell10.childAtIndexOrNull(0)!.path);
      // expect(selection.start.offset, 1);

      // cell11 = getCellNode(tableNode.node, 1, 1)!;
      // cell10 = getCellNode(tableNode.node, 1, 0)!;
      // expect(cell10.childAtIndexOrNull(0)!.delta?.toPlainText(), 'e');
      // expect(cell11.childAtIndexOrNull(0)!.delta?.toPlainText(), 'i');

      // await editor.dispose();
    });

    testWidgets('backspace on cell and after table node selection',
        (tester) async {
      final tableNode = TableNode.fromList([
        ['ab', 'cd'],
        ['ef', 'hi'],
      ]);
      final editor = tester.editor..addNode(tableNode.node);
      editor.addParagraph(initialText: 'Testing');

      await editor.startTesting();
      await tester.pumpAndSettle();

      var cell11 = getCellNode(tableNode.node, 1, 1)!;

      await editor.updateSelection(
        Selection(
          start: Position(
            path: cell11.childAtIndexOrNull(0)!.path,
            offset: 1,
          ),
          end: Position(
            path: editor.document.last!.path,
            offset: 3,
          ),
        ),
      );
      await simulateKeyDownEvent(LogicalKeyboardKey.backspace);

      var selection = editor.selection!;

      expect(selection.isCollapsed, true);
      expect(selection.start.path, cell11.childAtIndexOrNull(0)!.path);
      expect(selection.start.offset, 1);

      cell11 = getCellNode(tableNode.node, 1, 1)!;
      expect(cell11.childAtIndexOrNull(0)!.delta?.toPlainText(), 'h');
      expect(editor.document.last!.delta?.toPlainText(), 'ting');

      await editor.dispose();
    });

    testWidgets('backspace on whole table in selection', (tester) async {
      final tableNode = TableNode.fromList([
        ['ab', 'cd'],
        ['ef', 'hi'],
      ]);
      final editor = tester.editor..addParagraph(initialText: 'Start');
      editor.addNode(tableNode.node);
      editor.addParagraph(initialText: 'Testing');

      await editor.startTesting();
      await tester.pumpAndSettle();

      await editor.updateSelection(
        Selection(
          start: Position(
            path: editor.document.first!.path,
            offset: 1,
          ),
          end: Position(
            path: editor.document.last!.path,
            offset: 3,
          ),
        ),
      );
      await simulateKeyDownEvent(LogicalKeyboardKey.backspace);

      var selection = editor.selection!;

      expect(selection.isCollapsed, true);
      expect(selection.start.path, editor.document.first!.path);
      expect(selection.start.offset, 1);

      expect(editor.document.last!.delta?.toPlainText(), 'Sting');

      await editor.dispose();
    });

    testWidgets('up arrow key move to above row with same column',
        (tester) async {
      final tableNode = TableNode.fromList([
        ['ab', 'cde'],
        ['', ''],
      ]);
      final editor = tester.editor..addNode(tableNode.node);

      await editor.startTesting();
      await tester.pumpAndSettle();

      var cell01 = getCellNode(tableNode.node, 0, 1)!;
      var cell00 = getCellNode(tableNode.node, 0, 0)!;

      await editor.updateSelection(
        Selection.single(
          path: cell01.childAtIndexOrNull(0)!.path,
          startOffset: 1,
        ),
      );
      await simulateKeyDownEvent(LogicalKeyboardKey.arrowUp);

      var selection = editor.selection!;

      expect(selection.isCollapsed, true);
      expect(selection.start.path, cell00.childAtIndexOrNull(0)!.path);
      expect(selection.start.offset, 1);

      await editor.updateSelection(
        Selection.single(
          path: cell01.childAtIndexOrNull(0)!.path,
          startOffset: 3,
        ),
      );
      await simulateKeyDownEvent(LogicalKeyboardKey.arrowUp);

      selection = editor.selection!;

      expect(selection.isCollapsed, true);
      expect(selection.start.path, cell00.childAtIndexOrNull(0)!.path);
      expect(selection.start.offset, 2);
      await editor.dispose();
    });

    testWidgets('down arrow key move to down row with same column',
        (tester) async {
      final tableNode = TableNode.fromList([
        ['abc', 'de'],
        ['', ''],
      ]);
      final editor = tester.editor..addNode(tableNode.node);

      await editor.startTesting();
      await tester.pumpAndSettle();

      var cell01 = getCellNode(tableNode.node, 0, 1)!;
      var cell00 = getCellNode(tableNode.node, 0, 0)!;

      await editor.updateSelection(
        Selection.single(
          path: cell00.childAtIndexOrNull(0)!.path,
          startOffset: 1,
        ),
      );
      await simulateKeyDownEvent(LogicalKeyboardKey.arrowDown);

      var selection = editor.selection!;

      expect(selection.isCollapsed, true);
      expect(selection.start.path, cell01.childAtIndexOrNull(0)!.path);
      expect(selection.start.offset, 1);

      await editor.updateSelection(
        Selection.single(
          path: cell00.childAtIndexOrNull(0)!.path,
          startOffset: 3,
        ),
      );
      await simulateKeyDownEvent(LogicalKeyboardKey.arrowDown);

      selection = editor.selection!;

      expect(selection.isCollapsed, true);
      expect(selection.start.path, cell01.childAtIndexOrNull(0)!.path);
      expect(selection.start.offset, 2);
      await editor.dispose();
    });
  });
}
