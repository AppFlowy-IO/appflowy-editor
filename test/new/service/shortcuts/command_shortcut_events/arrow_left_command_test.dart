import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../infra/testable_editor.dart';
import '../../../util/util.dart';

// single | means the cursor
// double | means the selection
void main() async {
  setUpAll(() {
    if (kDebugMode) {
      activateLog();
    }
  });

  tearDownAll(() {
    if (kDebugMode) {
      deactivateLog();
    }
  });

  group('arrowLeft - widget test', () {
    const text = 'Welcome to AppFlowy Editor 🔥!';

    // Before
    // |Welcome to AppFlowy Editor 🔥!
    // After
    // |Welcome to AppFlowy Editor 🔥!
    testWidgets('press the left arrow key at the beginning of the document',
        (tester) async {
      final editor = tester.editor
        ..addParagraph(
          initialText: text,
        );
      await editor.startTesting();

      final selection = Selection.collapse(
        [0],
        0,
      );
      await editor.updateSelection(selection);

      await simulateKeyDownEvent(LogicalKeyboardKey.arrowLeft);
      expect(editor.selection, Selection.collapse([0], 0));

      await editor.dispose();
    });

    // Before
    // |Welcome| to AppFlowy Editor 🔥!
    // After
    // |Welcome to AppFlowy Editor 🔥!
    testWidgets('press the left arrow key at the collapsed selection',
        (tester) async {
      final editor = tester.editor
        ..addParagraph(
          initialText: text,
        );
      await editor.startTesting();

      final selection = Selection.single(
        path: [0],
        startOffset: 0,
        endOffset: 'Welcome'.length,
      );
      await editor.updateSelection(selection);

      await simulateKeyDownEvent(LogicalKeyboardKey.arrowLeft);
      expect(editor.selection, Selection.collapse([0], 0));

      await editor.dispose();
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
  });
}
