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

  group('home - widget test', () {
    const text = 'Welcome to AppFlowy Editor 🔥!';

    // Before
    // Welcome to AppFlowy Editor 🔥!|
    // After
    // |Welcome to AppFlowy Editor 🔥!
    testWidgets(
        'press the home key to go to the start of line if only one line',
        (tester) async {
      final editor = tester.editor
        ..addParagraph(
          initialText: text,
        );
      await editor.startTesting();

      final selection = Selection.collapse(
        [0],
        text.length,
      );
      await editor.updateSelection(selection);

      await simulateKeyDownEvent(LogicalKeyboardKey.home);

      // Home key on MacOS goes to the top of the page, since we only have one
      // paragraph in our page, the cursor is expected to move to the start
      // of line.
      expect(
        editor.selection,
        Selection.single(path: [0], startOffset: 0),
      );
      await editor.dispose();
    });

    testWidgets('press the home key to go to the start of page in macOs',
        (tester) async {
      final editor = tester.editor
        ..addParagraph(
          initialText: text,
        );

      editor.addParagraphs(10, initialText: text);
      await editor.startTesting();

      expect(editor.documentRootLen, 11);

      final selection = Selection.collapse(
        [10],
        text.length,
      );
      await editor.updateSelection(selection);

      await simulateKeyDownEvent(LogicalKeyboardKey.home);

      if (Platform.isMacOS) {
        expect(
          editor.selection,
          Selection.single(path: [0], startOffset: 0),
        );
      } else {
        expect(
          editor.selection,
          Selection.single(path: [10], startOffset: 0),
        );
      }
      await editor.dispose();
    });
  });
}
