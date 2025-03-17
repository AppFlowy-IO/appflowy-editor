import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../new/infra/testable_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('vim_fsm.dart', () {
    testWidgets('vim normal mode [j, k] horizontal keys (up/down)',
        (tester) async {
      const text1 = 'Welcome to Appflowy 😁';
      const text2 = 'Welcome';
      final editor = tester.editor
        ..addParagraph(initialText: text1)
        ..addParagraph(initialText: text2);

      await editor.startTesting();
      editor.editorState.vimMode = true;

      final selection = Selection.single(path: [1], startOffset: text2.length);
      await editor.updateSelection(selection);

      await editor.pressKey(key: LogicalKeyboardKey.escape);
      expect(editor.editorState.mode, VimModes.normalMode);

      await editor.pressKey(key: LogicalKeyboardKey.keyK);
      expect(
        editor.selection,
        Selection.single(path: [0], startOffset: 0),
      );

      await editor.pressKey(key: LogicalKeyboardKey.keyJ);
      expect(
        editor.selection,
        Selection.single(path: [1], startOffset: 0),
      );

      await editor.dispose();
    });

    testWidgets('vim normal mode horizontal keys left to right [h -> l]',
        (tester) async {
      const text1 = 'Welcome to Appflowy 😁';
      final editor = tester.editor..addParagraphs(2, initialText: text1);

      await editor.startTesting();
      editor.editorState.vimMode = true;

      final selection = Selection.single(path: [0], startOffset: 0);
      await editor.updateSelection(selection);

      await editor.pressKey(key: LogicalKeyboardKey.escape);

      expect(editor.editorState.mode, VimModes.normalMode);

      for (var i = 0; i < text1.length; i++) {
        await editor.pressKey(key: LogicalKeyboardKey.keyL);

        if (i == text1.length - 1) {
          // Wrap to next node if the cursor is at the end of the current node.
          expect(
            editor.selection,
            Selection.single(
              path: [1],
              startOffset: 0,
            ),
          );
        } else {
          final delta = editor.nodeAtPath([0])!.delta!;
          expect(
            editor.selection,
            Selection.single(
              path: [0],
              startOffset: delta.nextRunePosition(i),
            ),
          );
        }
      }
      await editor.dispose();
    });

    testWidgets('vim normal mode horizontal keys right to left [l -> h]',
        (tester) async {
      const text1 = 'Welcome to Appflowy 😁';
      final editor = tester.editor..addParagraphs(2, initialText: text1);

      await editor.startTesting();
      editor.editorState.vimMode = true;

      final selection = Selection.single(path: [0], startOffset: 0);
      await editor.updateSelection(selection);

      await editor.pressKey(key: LogicalKeyboardKey.escape);

      expect(editor.editorState.mode, VimModes.normalMode);

      for (var i = 0; i < text1.length; i++) {
        await editor.pressKey(key: LogicalKeyboardKey.keyL);

        if (i == text1.length - 1) {
          // Wrap to next node if the cursor is at the end of the current node.
          expect(
            editor.selection,
            Selection.single(
              path: [1],
              startOffset: 0,
            ),
          );
        } else {
          final delta = editor.nodeAtPath([0])!.delta!;
          expect(
            editor.selection,
            Selection.single(
              path: [0],
              startOffset: delta.nextRunePosition(i),
            ),
          );
        }
      }
      await editor.dispose();
    });

    testWidgets('vim normal mode move cursor to start', (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor..addParagraphs(2, initialText: text);

      await editor.startTesting();
      editor.editorState.vimMode = true;

      final selection = Selection.single(path: [1], startOffset: text.length);
      await editor.updateSelection(selection);

      await editor.pressKey(key: LogicalKeyboardKey.escape);

      expect(editor.editorState.mode, VimModes.normalMode);

      await editor.pressKey(key: LogicalKeyboardKey.digit0);

      expect(
        editor.selection,
        Selection.single(path: [1], startOffset: 0),
      );

      await editor.dispose();
    });
  });
}
