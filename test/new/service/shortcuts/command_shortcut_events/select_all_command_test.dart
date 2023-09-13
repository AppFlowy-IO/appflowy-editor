import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:io';

import '../../../infra/testable_editor.dart';

void main() async {
  group('select all - widget test', () {
    const text = 'Welcome to AppFlowy Editor 🔥!';

    testWidgets('select all in non-nested document', (tester) async {
      const count = 100;
      final editor = tester.editor..addParagraphs(count, initialText: text);
      await editor.startTesting();

      final selection = Selection.collapsed(Position(path: [0]));
      await editor.updateSelection(selection);

      await editor.pressKey(
        key: LogicalKeyboardKey.keyA,
        isMetaPressed: Platform.isMacOS,
        isControlPressed: Platform.isWindows || Platform.isLinux,
      );

      expect(
        editor.selection,
        Selection(
          start: Position(path: [0], offset: 0),
          end: Position(path: [count - 1], offset: text.length),
        ),
      );

      await editor.dispose();
    });

    // Before
    // Welcome to AppFlowy Editor 🔥!
    //  Welcome to AppFlowy Editor 🔥!
    //    Welcome to AppFlowy Editor 🔥!
    // After
    // |Welcome to AppFlowy Editor 🔥!
    //  Welcome to AppFlowy Editor 🔥!
    //    Welcome to AppFlowy Editor 🔥!|
    testWidgets('select all in nested document', (tester) async {
      final editor = tester.editor
        ..addNode(
          paragraphNode(
            text: text,
            children: [
              paragraphNode(
                text: text,
                children: [paragraphNode(text: text)],
              ),
            ],
          ),
        );
      await editor.startTesting();

      final selection = Selection.collapsed(Position(path: [0]));
      await editor.updateSelection(selection);

      await editor.pressKey(
        key: LogicalKeyboardKey.keyA,
        isMetaPressed: Platform.isMacOS,
        isControlPressed: Platform.isWindows || Platform.isLinux,
      );
      expect(
        editor.selection,
        Selection(
          start: Position(path: [0], offset: 0),
          end: Position(path: [0, 0, 0], offset: text.length),
        ),
      );

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

      final selection =
          Selection.collapsed(Position(path: [1], offset: text.length));
      await editor.updateSelection(selection);

      // move the cursor to the beginning of node 1
      for (var i = 1; i < text.length; i++) {
        await simulateKeyDownEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pumpAndSettle();
      }
      expect(editor.selection, Selection.collapsed(Position(path: [1])));

      // move the cursor to the ending of node 0
      await simulateKeyDownEvent(LogicalKeyboardKey.arrowLeft);
      expect(
        editor.selection,
        Selection.collapsed(Position(path: [0], offset: text.length)),
      );

      // move the cursor to the beginning of node 0
      for (var i = 1; i < text.length; i++) {
        await simulateKeyDownEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pumpAndSettle();
      }
      expect(editor.selection, Selection.collapsed(Position(path: [0])));

      await editor.dispose();
    });
  });
}
