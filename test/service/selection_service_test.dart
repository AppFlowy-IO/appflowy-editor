import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/util.dart';
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

    testWidgets('Test double tap then drag forward selects whole words',
        (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor..addParagraphs(3, initialText: text);
      await editor.startTesting();

      final secondNode = editor.nodeAtPath([1]);
      final finder = find.byKey(secondNode!.key);
      final rect = tester.getRect(finder);

      // Press inside the first word "Welcome" (not at its start).
      final startPos = rect.centerLeft + const Offset(10.0, 0.0);

      // First tap of the double-tap.
      await tester.tapAt(startPos);
      // Second tap: press down, hold briefly (so the double-tap is recognized),
      // then drag to the end of the line.
      final gesture = await tester.startGesture(
        startPos,
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump(const Duration(milliseconds: 150));
      // A small move starts the drag, then extend to the end of the line.
      await gesture.moveTo(startPos + const Offset(30.0, 0.0));
      await tester.pump();
      await gesture.moveTo(rect.centerRight);
      await tester.pump();
      await gesture.up();
      await tester.pump();

      // The whole first word stays selected (start at offset 0, not mid-word)
      // and the selection extends by whole words to the end of the line.
      expect(
        editor.selection?.normalized,
        Selection.single(path: [1], startOffset: 0, endOffset: text.length),
      );

      await editor.dispose();
    });

    testWidgets('Test double tap then drag backward keeps the anchor word',
        (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor..addParagraphs(3, initialText: text);
      await editor.startTesting();

      final secondNode = editor.nodeAtPath([1]);
      final finder = find.byKey(secondNode!.key);
      final rect = tester.getRect(finder);

      // Probe which word lives further along the line so the assertion does not
      // depend on exact glyph widths.
      final probePos = rect.centerLeft + const Offset(120.0, 0.0);
      await tester.tapAt(probePos);
      await tester.tapAt(probePos);
      await tester.pump();
      final probeWord = editor.selection!.normalized;
      expect(probeWord.start.offset, greaterThan(0));

      // Reset with a plain tap (also clears any pending word-drag anchor).
      await tester.tapAt(rect.centerLeft);
      await tester.pump();

      // Double-tap that later word, then hold and drag back to the start.
      await tester.tapAt(probePos);
      final gesture = await tester.startGesture(
        probePos,
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump(const Duration(milliseconds: 150));
      // A small move starts the drag, then extend back to the start of the line.
      await gesture.moveTo(probePos - const Offset(30.0, 0.0));
      await tester.pump();
      await gesture.moveTo(rect.centerLeft);
      await tester.pump();
      await gesture.up();
      await tester.pump();

      // The double-tapped word's end stays selected and the selection extends
      // by whole words back to the start of the line.
      expect(
        editor.selection?.normalized,
        Selection.single(
          path: [1],
          startOffset: 0,
          endOffset: probeWord.end.offset,
        ),
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

    testWidgets(
      'Test secondary tap (right-click) - no selection creates collapsed selection',
      (tester) async {
        const text = 'Welcome to Appflowy 😁';
        final editor = tester.editor..addParagraphs(3, initialText: text);
        await editor.startTesting();

        final secondNode = editor.nodeAtPath([1]);
        final finder = find.byKey(secondNode!.key);

        final rect = tester.getRect(finder);
        expect(editor.selection, isNull);

        await tester.tapAt(
          rect.centerLeft + const Offset(50.0, 0.0),
          buttons: kSecondaryButton,
        );
        await tester.pump();

        expect(editor.selection, isNotNull);
        expect(editor.selection!.isCollapsed, isTrue);
        expect(editor.selection!.start.path, [1]);

        final contextMenu = find.byType(ContextMenu);
        expect(contextMenu, findsOneWidget);

        await editor.dispose();
      },
    );

    testWidgets(
      'Test secondary tap - collapsed selection remains unchanged',
      (tester) async {
        const text = 'Welcome to Appflowy 😁';
        final editor = tester.editor..addParagraphs(3, initialText: text);
        await editor.startTesting();

        final secondNode = editor.nodeAtPath([1]);
        final finder = find.byKey(secondNode!.key);

        final rect = tester.getRect(finder);

        await tester.tapAt(rect.centerLeft + const Offset(30.0, 0.0));
        await tester.pump();

        final originalSelection = editor.selection;
        expect(originalSelection, isNotNull);
        expect(originalSelection!.isCollapsed, isTrue);

        await tester.tapAt(
          rect.centerLeft + const Offset(80.0, 0.0),
          buttons: kSecondaryButton,
        );
        await tester.pump();

        expect(editor.selection, equals(originalSelection));

        final contextMenu = find.byType(ContextMenu);
        expect(contextMenu, findsOneWidget);

        await editor.dispose();
      },
    );

    testWidgets(
      'Test secondary tap - non-collapsed selection remains when tapping within selected node',
      (tester) async {
        const text = 'Welcome to Appflowy 😁';
        final editor = tester.editor..addParagraphs(3, initialText: text);
        await editor.startTesting();

        final secondNode = editor.nodeAtPath([1]);
        final finder = find.byKey(secondNode!.key);

        final rect = tester.getRect(finder);

        await tester.tapAt(rect.centerLeft + const Offset(10.0, 0.0));
        await tester.tapAt(rect.centerLeft + const Offset(10.0, 0.0));
        await tester.pumpAndSettle();

        final originalSelection = editor.selection;
        expect(originalSelection, isNotNull);
        expect(originalSelection!.isCollapsed, isFalse);
        expect(originalSelection.start.path, [1]);
        expect(originalSelection.end.path, [1]);

        await tester.tapAt(
          rect.centerLeft + const Offset(20.0, 0.0),
          buttons: kSecondaryButton,
        );
        await tester.pumpAndSettle();

        expect(editor.selection, equals(originalSelection));

        final contextMenu = find.byType(ContextMenu);
        expect(contextMenu, findsOneWidget);

        await editor.dispose();
      },
    );

    testWidgets(
      'Test secondary tap - multi-node selection remains when tapping within selected nodes',
      (tester) async {
        const text = 'Welcome to Appflowy 😁';
        final editor = tester.editor..addParagraphs(3, initialText: text);
        await editor.startTesting();

        final firstNode = editor.nodeAtPath([0]);
        final secondNode = editor.nodeAtPath([1]);
        final firstFinder = find.byKey(firstNode!.key);
        final secondFinder = find.byKey(secondNode!.key);

        final firstRect = tester.getRect(firstFinder);
        final secondRect = tester.getRect(secondFinder);

        await tester.timedDragFrom(
          firstRect.centerLeft + const Offset(10.0, 0.0),
          secondRect.center - firstRect.centerLeft - const Offset(10.0, 0.0),
          const Duration(milliseconds: 500),
        );
        await tester.pumpAndSettle();

        final originalSelection = editor.selection;
        expect(originalSelection, isNotNull);
        expect(originalSelection!.isCollapsed, isFalse);

        await tester.tapAt(
          secondRect.centerLeft + const Offset(30.0, 0.0),
          buttons: kSecondaryButton,
        );
        await tester.pump();

        expect(editor.selection, equals(originalSelection));

        final contextMenu = find.byType(ContextMenu);
        expect(contextMenu, findsOneWidget);

        await editor.dispose();
      },
    );

    testWidgets(
      'Test secondary tap - selection changes when tapping outside selected nodes',
      (tester) async {
        const text = 'Welcome to Appflowy 😁';
        final editor = tester.editor..addParagraphs(3, initialText: text);
        await editor.startTesting();

        final firstNode = editor.nodeAtPath([0]);
        final secondNode = editor.nodeAtPath([1]);
        final thirdNode = editor.nodeAtPath([2]);
        final firstFinder = find.byKey(firstNode!.key);
        final secondFinder = find.byKey(secondNode!.key);
        final thirdFinder = find.byKey(thirdNode!.key);

        final firstRect = tester.getRect(firstFinder);
        final secondRect = tester.getRect(secondFinder);
        final thirdRect = tester.getRect(thirdFinder);

        await tester.timedDragFrom(
          firstRect.centerLeft + const Offset(10.0, 0.0),
          secondRect.center - firstRect.centerLeft - const Offset(10.0, 0.0),
          const Duration(milliseconds: 500),
        );
        await tester.pumpAndSettle();

        final originalSelection = editor.selection;
        expect(originalSelection, isNotNull);
        expect(originalSelection!.isCollapsed, isFalse);

        await tester.tapAt(
          thirdRect.centerLeft + const Offset(30.0, 0.0),
          buttons: kSecondaryButton,
        );
        await tester.pump();

        expect(editor.selection, isNotNull);
        expect(editor.selection!.isCollapsed, isTrue);
        expect(editor.selection!.start.path, [2]);
        expect(editor.selection, isNot(equals(originalSelection)));

        final contextMenu = find.byType(ContextMenu);
        expect(contextMenu, findsOneWidget);

        await editor.dispose();
      },
    );

    testWidgets(
      'Test secondary tap - toolbar re-enabled when context menu is dismissed by clicking mask',
      (tester) async {
        const text = 'Welcome to Appflowy 😁';
        final editor = tester.editor..addParagraphs(3, initialText: text);
        await editor.startTesting();

        final secondNode = editor.nodeAtPath([1]);
        final finder = find.byKey(secondNode!.key);

        final rect = tester.getRect(finder);

        await tester.tapAt(rect.centerLeft + const Offset(10.0, 0.0));
        await tester.tapAt(rect.centerLeft + const Offset(10.0, 0.0));
        await tester.pumpAndSettle();

        final originalSelection = editor.selection;
        expect(originalSelection, isNotNull);
        expect(originalSelection!.isCollapsed, isFalse);

        await tester.tapAt(
          rect.centerLeft + const Offset(20.0, 0.0),
          buttons: kSecondaryButton,
        );
        await tester.pumpAndSettle();

        final contextMenu = find.byType(ContextMenu);
        expect(contextMenu, findsOneWidget);

        await tester.tapAt(const Offset(10.0, 10.0));
        await tester.pumpAndSettle();

        expect(find.byType(ContextMenu), findsNothing);

        expect(editor.selection, equals(originalSelection));
        expect(editor.selection, isNotNull);

        await editor.dispose();
      },
    );

    testWidgets(
      'Test secondary tap - context menu and toolbar behavior',
      (tester) async {
        const text = 'Welcome to Appflowy 😁';
        final editor = tester.editor..addParagraphs(3, initialText: text);
        await editor.startTesting();

        final secondNode = editor.nodeAtPath([1]);
        final finder = find.byKey(secondNode!.key);

        final rect = tester.getRect(finder);

        await tester.tapAt(rect.centerLeft + const Offset(10.0, 0.0));
        await tester.tapAt(rect.centerLeft + const Offset(10.0, 0.0));
        await tester.pumpAndSettle();

        final originalSelection = editor.selection;
        expect(originalSelection, isNotNull);
        expect(originalSelection!.isCollapsed, isFalse);

        await tester.tapAt(
          rect.centerLeft + const Offset(20.0, 0.0),
          buttons: kSecondaryButton,
        );
        await tester.pumpAndSettle();

        final contextMenu = find.byType(ContextMenu);
        expect(contextMenu, findsOneWidget);

        await tester.tapAt(const Offset(10.0, 10.0));
        await tester.pumpAndSettle();

        expect(find.byType(ContextMenu), findsNothing);
        expect(editor.selection, isNotNull);

        await editor.dispose();
      },
    );

    testWidgets(
      'Test secondary tap - shortcuts blocked when context menu shows',
      (tester) async {
        const text = 'Welcome to Appflowy 😁';
        final editor = tester.editor..addParagraphs(3, initialText: text);
        await editor.startTesting();

        final secondNode = editor.nodeAtPath([1]);
        final finder = find.byKey(secondNode!.key);

        final rect = tester.getRect(finder);

        await tester.tapAt(rect.centerLeft + const Offset(10.0, 0.0));
        await tester.tapAt(rect.centerLeft + const Offset(10.0, 0.0));
        await tester.pumpAndSettle();

        final originalSelection = editor.selection;
        expect(originalSelection, isNotNull);
        expect(originalSelection!.isCollapsed, isFalse);

        await tester.tapAt(
          rect.centerLeft + const Offset(20.0, 0.0),
          buttons: kSecondaryButton,
        );
        await tester.pumpAndSettle();

        final contextMenu = find.byType(ContextMenu);
        expect(contextMenu, findsOneWidget);

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();

        expect(editor.selection, equals(originalSelection));

        await tester.tapAt(const Offset(10.0, 10.0));
        await tester.pumpAndSettle();

        expect(find.byType(ContextMenu), findsNothing);

        await editor.dispose();
      },
    );

    testWidgets('single tap with horizontal nodes', (tester) async {
      final tableNode = TableNode.fromList([
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
