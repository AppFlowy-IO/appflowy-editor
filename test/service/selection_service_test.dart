import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/util.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_node.dart';
import '../new/infra/testable_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('selection_service.dart', () {
    testWidgets('Single tap test ', (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor..addParagraphs(3, initialText: text);
      await editor.startTesting();

      final secondNode = editor.nodeAtPath([1]);
      final finder = find.byKey(secondNode!.key);

      final rect = tester.getRect(finder);
      // tap at the beginning
      await tester.tapAt(rect.centerLeft);
      expect(
        editor.selection,
        Selection.single(path: [1], startOffset: 0),
      );

      await tester.pumpAndSettle(const Duration(seconds: 1));
      // tap at the ending
      await tester.tapAt(rect.centerRight);
      expect(
        editor.selection,
        Selection.single(path: [1], startOffset: text.length),
      );

      await editor.dispose();
    });

    testWidgets('Test double tap', (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor..addParagraphs(3, initialText: text);
      await editor.startTesting();

      final secondNode = editor.nodeAtPath([1]);
      final finder = find.byKey(secondNode!.key);

      final rect = tester.getRect(finder);
      // double tap
      await tester.tapAt(rect.centerLeft + const Offset(10.0, 0.0));
      await tester.tapAt(rect.centerLeft + const Offset(10.0, 0.0));
      await tester.pump();
      expect(
        editor.selection,
        Selection.single(path: [1], startOffset: 0, endOffset: 7),
      );

      await editor.dispose();
    });

    testWidgets('Test triple tap', (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor..addParagraphs(3, initialText: text);
      await editor.startTesting();

      final secondNode = editor.nodeAtPath([1]);
      final finder = find.byKey(secondNode!.key);

      final rect = tester.getRect(finder);
      // triple tap
      await tester.tapAt(rect.centerLeft + const Offset(10.0, 0.0));
      await tester.tapAt(rect.centerLeft + const Offset(10.0, 0.0));
      await tester.tapAt(rect.centerLeft + const Offset(10.0, 0.0));
      await tester.pump();
      expect(
        editor.selection,
        Selection.single(path: [1], startOffset: 0, endOffset: text.length),
      );

      await editor.dispose();
    });

    // TODO: lucas.xu support context menu
    // testWidgets('Test secondary tap', (tester) async {
    //   const text = 'Welcome to Appflowy 😁';
    //   final editor = tester.editor..addParagraphs(3, initialText: text);
    //   await editor.startTesting();

    //   final secondNode = editor.nodeAtPath([1]) as Node;
    //   final finder = find.byKey(secondNode.key);

    //   final rect = tester.getRect(finder);
    //   // secondary tap
    //   await tester.tapAt(
    //     rect.centerLeft + const Offset(10.0, 0.0),
    //     buttons: kSecondaryButton,
    //   );
    //   await tester.pump();

    //   const welcome = 'Welcome';
    //   expect(
    //     editor.selection,
    //     Selection.single(
    //       path: [1],
    //       startOffset: 0,
    //       endOffset: welcome.length,
    //     ), // Welcome
    //   );

    //   final contextMenu = find.byType(ContextMenu);
    //   expect(contextMenu, findsOneWidget);

    //   // test built in context menu items

    //   // Skip the Windows platform because the rich_clipboard package doesn't support it perfectly.
    //   if (Platform.isWindows) {
    //     return;
    //   }

    //   // cut
    //   await tester.tap(find.text('Cut'));
    //   await tester.pump();
    //   expect(
    //     secondNode.delta!.toPlainText(),
    //     text.replaceAll(welcome, ''),
    //   );
    //
    //   await editor.dispose();
    //   // TODO: the copy and paste test is not working during test env.
    // });

    testWidgets('single tap with horizontal nodes', (tester) async {
      var tableNode = TableNode.fromList([
        ['00', '01', '02', '03', '04'],
        ['10', '11', '12', '13', '14'],
        ['20', '21', '22', '23', '24'],
        ['30', '31', '32', '33', '34'],
        ['40', '41', '42', '43', '44'],
        ['50', '51', '52', '53', '54'],
        ['60', '61', '62', '63', '64'],
        ['70', '71', '72', '73', '74'],
        ['80', '81', '82', '83', '84'],
      ]);
      final editor = tester.editor..addNode(tableNode.node);
      await editor.startTesting();

      final cell04 = getCellNode(tableNode.node, 0, 4);
      final finder = find.byKey(cell04!.key);

      final rect = tester.getRect(finder);
      // tap at the beginning
      await tester.tapAt(rect.centerLeft);
      expect(
        editor.selection,
        Selection.single(
          path: cell04.childAtIndexOrNull(0)!.path,
          startOffset: 0,
        ),
      );

      await editor.dispose();
    });

    testWidgets('Block selection and then single tap', (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor..addParagraph(initialText: text);
      await editor.startTesting();

      final firstNode = editor.nodeAtPath([0]);
      final finder = find.byKey(firstNode!.key);

      final rect = tester.getRect(finder);

      editor.editorState.selectionType = SelectionType.block;

      // tap at the beginning
      await tester.tapAt(rect.centerLeft);
      expect(
        editor.selection,
        Selection.single(path: [0], startOffset: 0),
      );

      expect(editor.editorState.selectionType, SelectionType.inline);

      await editor.dispose();
    });
  });
}
