import 'dart:io' show Platform;
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../infra/testable_editor.dart';
import '../../../util/util.dart';

// single | means the cursor
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

  group('end - widget test', () {
    const text = 'Welcome to AppFlowy Editor 🔥!';

    // Before
    // Welcome to AppFlowy Editor 🔥!|
    // After
    // |Welcome to AppFlowy Editor 🔥!
    testWidgets('press the end key to go to the end of line if only one line',
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

      await simulateKeyDownEvent(LogicalKeyboardKey.end);

      // End key on MacOS scrolls to the end of the page, since we only have one
      // paragraph in our page, the cursor is expected to move to the end
      // of line.
      expect(
        editor.selection,
        Selection.single(path: [0], startOffset: text.length),
      );
      await editor.dispose();
    });

    testWidgets('press the end key to go to the end of page in macOs',
        (tester) async {
      final editor = tester.editor
        ..addParagraph(
          initialText: text,
        );

      editor.addParagraphs(10, initialText: text);
      await editor.startTesting();

      expect(editor.documentRootLen, 11);

      final selection = Selection.collapse(
        [0],
        0,
      );
      await editor.updateSelection(selection);

      await simulateKeyDownEvent(LogicalKeyboardKey.end);

      if (Platform.isMacOS) {
        expect(
          editor.selection,
          Selection.single(path: [10], startOffset: text.length),
        );
      } else {
        expect(
          editor.selection,
          Selection.single(path: [0], startOffset: text.length),
        );
      }
      await editor.dispose();
    });
  });
}
