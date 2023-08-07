import 'dart:io' show Platform;
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../infra/testable_editor.dart';

// single | means the cursor
void main() async {
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

      final selection =
          Selection.collapsed(Position(path: [0], offset: text.length));
      await editor.updateSelection(selection);

      await simulateKeyDownEvent(LogicalKeyboardKey.home);

      if (Platform.isWindows || Platform.isLinux) {
        expect(
          editor.selection,
          Selection.single(path: [0], startOffset: 0),
        );
      }
      //On Mac OS, the document will scroll to the top but the selection
      //will not be updated.

      await editor.dispose();
    });

    testWidgets('press the home key to go to the start of selected line',
        (tester) async {
      final editor = tester.editor..addParagraphs(10, initialText: text);

      await editor.startTesting();

      expect(editor.documentRootLen, 10);

      final selection =
          Selection.collapsed(Position(path: [5], offset: text.length));
      await editor.updateSelection(selection);

      await simulateKeyDownEvent(LogicalKeyboardKey.home);

      if (Platform.isWindows || Platform.isLinux) {
        expect(
          editor.selection,
          Selection.single(path: [5], startOffset: 0),
        );
      }
      //On Mac OS, the document will scroll to the top but the selection
      //will not be updated.

      await editor.dispose();
    });

    //shift+home is only supported in windows and linux
    // Before
    // Welcome to AppFlowy Editor 🔥!|
    // After
    // |Welcome to AppFlowy Editor 🔥!|
    testWidgets('press the shift + home to select till beginning of line',
        (tester) async {
      if (!Platform.isMacOS) {
        final editor = tester.editor
          ..addParagraph(
            initialText: text,
          );
        await editor.startTesting();

        final selection =
            Selection.collapsed(Position(path: [0], offset: text.length));
        await editor.updateSelection(selection);

        await editor.pressKey(
          key: LogicalKeyboardKey.home,
          isShiftPressed: true,
        );

        expect(
          editor.selection,
          Selection.single(
            path: [0],
            startOffset: text.length,
            endOffset: 0,
          ),
        );

        await editor.dispose();
      }
    });
  });
}
