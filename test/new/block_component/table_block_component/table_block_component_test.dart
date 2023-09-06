import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_node.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../infra/testable_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('table_block_component.dart', () {
    testWidgets('render table node', (tester) async {
      final tableNode = TableNode.fromList([
        [''],
      ]);
      final editor = tester.editor..addNode(tableNode.node);

      await editor.startTesting();
      await tester.pumpAndSettle();

      expect(editor.documentRootLen, 1);
      expect(find.byType(TableBlockComponentWidget), findsOneWidget);
      expect(tableNode.colsLen, 1);
      expect(tableNode.rowsLen, 1);
      expect(tableNode.node.children.length, 1);
      expect(
        tableNode.node.children.first.children.first.type,
        ParagraphBlockKeys.type,
      );
      await editor.dispose();
    });

    /*testWidgets('table delete action', (tester) async {
      final table = TableNode.fromList([
        ['']
      ]);
      final editor = tester.editor..addNode(table.node);

      await editor.startTesting();
      await tester.pumpAndSettle();

      expect(editor.documentLength, 1);
      expect(find.byType(TableBlockComponentWidget), findsOneWidget);

      final tableNode = editor.document.nodeAtPath([0]);
      expect(editor.runAction(1, tableNode!), true);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(TableBlockComponentWidget), findsNothing);
      await editor.dispose();
    });

    testWidgets('table duplicate action', (tester) async {
      final table = TableNode.fromList([
        ['']
      ]);
      final editor = tester.editor..addNode(table.node);

      await editor.startTesting();
      await tester.pumpAndSettle();

      expect(find.byType(TableBlockComponentWidget), findsOneWidget);

      final tableNode = editor.document.nodeAtPath([0]);
      expect(editor.runAction(0, tableNode!), true);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(TableBlockComponentWidget), findsNWidgets(2));
      await editor.dispose();
    });*/
  });
}
