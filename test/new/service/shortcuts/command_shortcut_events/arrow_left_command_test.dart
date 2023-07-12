import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../infra/testable_editor.dart';
import '../../../util/util.dart';

// single | means the cursor
// double | means the selection
void main() async {
  group('arrowLeft - widget test', () {
    const text = 'Welcome to AppFlowy Editor 🔥!';

    // Before
    // |Welcome to AppFlowy Editor 🔥!
    // After
    // |Welcome to AppFlowy Editor 🔥!
    testWidgets('press the left arrow key at the beginning of the document',
        (tester) async {
      final arrowLeftTest = ArrowTest(
        text: text,
        initialSel: Selection.collapse(
          [0],
          0,
        ),
        expSel: Selection.collapse(
          [0],
          0,
        ),
      );

      await runArrowLeftTest(tester, arrowLeftTest);
    });

    // Before
    // |Welcome| to AppFlowy Editor 🔥!
    // After
    // |Welcome to AppFlowy Editor 🔥!
    testWidgets('press the left arrow key at the collapsed selection',
        (tester) async {
      final selection = Selection.single(
        path: [0],
        startOffset: 0,
        endOffset: 'Welcome'.length,
      );
      final arrowLeftTest = ArrowTest(
        text: text,
        initialSel: selection,
        expSel: selection.collapse(atStart: true),
      );

      await runArrowLeftTest(tester, arrowLeftTest);
    });

    // Before
    // Welcome to AppFlowy Editor 🔥!
    // Welcome to AppFlowy Editor 🔥!|
    // After
    // |Welcome to AppFlowy Editor 🔥!
    // Welcome to AppFlowy Editor 🔥!
    testWidgets(
        'press the left arrow key until it reaches the beginning of the document',
        (tester) async {
      final editor = tester.editor
        ..addParagraphs(
          2,
          initialText: text,
        );
      await editor.startTesting();

      final selection = Selection.collapse(
        [1],
        text.length,
      );
      await editor.updateSelection(selection);

      // move the cursor to the beginning of node 1
      for (var i = 1; i < text.length; i++) {
        await simulateKeyDownEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pumpAndSettle();
      }
      expect(editor.selection, Selection.collapse([1], 0));

      // move the cursor to the ending of node 0
      await simulateKeyDownEvent(LogicalKeyboardKey.arrowLeft);
      expect(editor.selection, Selection.collapse([0], text.length));

      // move the cursor to the beginning of node 0
      for (var i = 1; i < text.length; i++) {
        await simulateKeyDownEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pumpAndSettle();
      }
      expect(editor.selection, Selection.collapse([0], 0));

      await editor.dispose();
    });

    testWidgets('rtl text', (tester) async {
      final List<ArrowTest> tests = [
        ArrowTest(
          text: 'به ویرایشگر Appflowy خوش آمدید 🔥!',
          decorator: (i, n) => n.updateAttributes({
            blockComponentTextDirection: blockComponentTextDirectionRTL,
          }),
          initialSel: Selection.collapse(
            [0],
            0,
          ),
          expSel: Selection.collapse(
            [0],
            1,
          ),
        ),
        ArrowTest(
          text: 'به ویرایشگر Appflowy خوش آمدید 🔥!',
          decorator: (i, n) => n.updateAttributes({
            blockComponentTextDirection: blockComponentTextDirectionRTL,
          }),
          initialSel: Selection.collapse(
            [0],
            'به ویرایشگر Appflowy خوش آمدید 🔥!'.length,
          ),
          expSel: Selection.collapse(
            [0],
            'به ویرایشگر Appflowy خوش آمدید 🔥!'.length,
          ),
        ),
        ArrowTest(
          text: 'به ویرایشگر Appflowy خوش آمدید 🔥!',
          decorator: (i, n) => n.updateAttributes({
            blockComponentTextDirection: blockComponentTextDirectionRTL,
          }),
          initialSel: Selection.single(
            path: [0],
            startOffset: 0,
            endOffset: 'به ویرایشگ'.length,
          ),
          expSel: Selection.collapse(
            [0],
            'به ویرایشگ'.length,
          ),
        ),
      ];

      for (var i = 0; i < tests.length; i++) {
        await runArrowLeftTest(
          tester,
          tests[i],
          "Test $i: text='${tests[i].text}'",
        );
      }
    });
  });
}
