import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';
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

    //   await editor.dispose();
    //   // TODO: the copy and paste test is not working during test env.
    // });
  });
}
