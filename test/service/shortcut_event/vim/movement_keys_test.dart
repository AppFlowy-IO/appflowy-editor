import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
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
/*
    testWidgets('redefine move cursor end command', (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor..addParagraphs(2, initialText: text);

      await editor.startTesting();

      final selection = Selection.single(path: [1], startOffset: 0);
      await editor.updateSelection(selection);

      await editor.pressKey(
        key: Platform.isMacOS
            ? LogicalKeyboardKey.arrowRight
            : LogicalKeyboardKey.end,
        isMetaPressed: Platform.isMacOS,
      );

      expect(
        editor.selection,
        Selection.single(path: [1], startOffset: text.length),
      );

      await editor.updateSelection(selection);

      const newCommand = 'alt+arrow right';
      moveCursorToEndCommand.updateCommand(
        windowsCommand: newCommand,
        linuxCommand: newCommand,
        macOSCommand: newCommand,
      );

      await editor.pressKey(
        key: LogicalKeyboardKey.arrowRight,
        isAltPressed: true,
      );

      expect(
        editor.selection,
        Selection.single(path: [1], startOffset: text.length),
      );

      await editor.dispose();
    });
    */
  });
}
