import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:io' show Platform;

import '../../../new/infra/testable_editor.dart';
import '../../../new/util/util.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });
  group('vim.dart', () {
    testWidgets('vim normal mode move cursor to start', (tester) async {
      const text1 = 'Welcome to Appflowy 😁';
      const text2 = 'Welcome';
      final editor = tester.editor
        ..addParagraph(initialText: text1)
        ..addParagraph(initialText: text2);

      await editor.startTesting();
      editor.editorState.vimMode = true;

      final selection =
          Selection.collapsed(Position(path: [1], offset: text2.length));
      await editor.updateSelection(selection);

      await editor.pressKey(key: LogicalKeyboardKey.escape);
      expect(editor.editorState.mode, VimModes.normalMode);

      await editor.pressKey(
        key: LogicalKeyboardKey.digit0,
      );

      expect(
        editor.selection,
        Selection.single(path: [1], startOffset: 0),
      );

      await editor.dispose();
    });
    testWidgets('vim normal mode move cursor to end from start',
        (tester) async {
      const text1 = 'Welcome to Appflowy 😁';
      const text2 = 'Welcome';
      final editor = tester.editor
        ..addParagraph(initialText: text1)
        ..addParagraph(initialText: text2);

      await editor.startTesting();
      editor.editorState.vimMode = true;

      final selection = Selection.collapsed(Position(path: [1], offset: 0));
      await editor.updateSelection(selection);

      await editor.pressKey(key: LogicalKeyboardKey.escape);
      expect(editor.editorState.mode, VimModes.normalMode);

      await editor.pressKey(
        key: LogicalKeyboardKey.digit4,
        isShiftPressed: true,
      );
      if (Platform.isWindows || Platform.isLinux) {
        expect(
          editor.selection,
          Selection.single(path: [1], startOffset: text2.length),
        );
      }

      await editor.dispose();
    });

    testWidgets('vim normal mode delete 2 lines (2dd)', (tester) async {
      const text1 = 'Welcome to Appflowy 😁';
      const text2 = 'Welcome';
      final editor = tester.editor..addParagraphs(6, initialText: text1);

      await editor.startTesting();
      editor.editorState.vimMode = true;

      final selection =
          Selection.collapsed(Position(path: [1], offset: text2.length));
      await editor.updateSelection(selection);

      await editor.pressKey(key: LogicalKeyboardKey.escape);
      expect(editor.editorState.mode, VimModes.normalMode);

      await editor.pressKey(
        key: LogicalKeyboardKey.digit2,
      );

      await editor.pressKey(
        key: LogicalKeyboardKey.keyD,
      );

      await editor.pressKey(
        key: LogicalKeyboardKey.keyD,
      );

      expect(editor.document.root.children.length, equals(4));

      expect(
        editor.selection,
        Selection.single(path: [1], startOffset: 0),
      );

      await editor.dispose();
    });
    testWidgets('vim normal mode delete 1 line (dd)', (tester) async {
      const text1 = 'Welcome to Appflowy 😁';
      const text2 = 'Welcome';
      final editor = tester.editor..addParagraphs(6, initialText: text1);

      await editor.startTesting();
      editor.editorState.vimMode = true;

      final selection =
          Selection.collapsed(Position(path: [1], offset: text2.length));
      await editor.updateSelection(selection);

      await editor.pressKey(key: LogicalKeyboardKey.escape);
      expect(editor.editorState.mode, VimModes.normalMode);

      await editor.pressKey(
        key: LogicalKeyboardKey.keyD,
      );

      await editor.pressKey(
        key: LogicalKeyboardKey.keyD,
      );

      expect(editor.document.root.children.length, equals(5));

      expect(
        editor.selection,
        Selection.single(path: [1], startOffset: 0),
      );

      await editor.dispose();
    });

    testWidgets('vim normal mode delete then perform undo and redo',
        (tester) async {
      const text1 = 'Welcome to Appflowy 😁';
      const text2 = 'Welcome';
      final editor = tester.editor..addParagraphs(6, initialText: text1);

      await editor.startTesting();
      editor.editorState.vimMode = true;

      final selection =
          Selection.collapsed(Position(path: [0], offset: text1.length));
      await editor.updateSelection(selection);

      await editor.pressKey(key: LogicalKeyboardKey.escape);
      expect(editor.editorState.mode, VimModes.normalMode);

      await editor.pressKey(
        key: LogicalKeyboardKey.keyD,
      );

      await editor.pressKey(
        key: LogicalKeyboardKey.keyD,
      );
      await tester.pumpAndSettle();

      expect(editor.document.root.children.length, equals(5));

      expect(
        editor.selection,
        Selection.single(path: [0], startOffset: 0),
      );

      await editor.pressKey(key: LogicalKeyboardKey.keyU);
      await tester.pumpAndSettle();
      expect(editor.document.root.children.length, equals(6));

      expect(
        editor.selection,
        Selection.single(path: [0], startOffset: text1.length),
      );

      await editor.pressKey(
          key: LogicalKeyboardKey.keyR, isControlPressed: true);
      await tester.pumpAndSettle();

      expect(editor.document.root.children.length, equals(5));

      expect(
        editor.selection,
        Selection.single(path: [0], startOffset: text1.length),
      );

      await editor.dispose();
    });
  });
}
