import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:io' show Platform;

import '../../../new/infra/testable_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('vim.dart', () {
    testWidgets('vim normal mode move cursor to end', (tester) async {
      const text1 = 'Welcome to Appflowy 😁';
      const text2 = 'Welcome';
      final editor = tester.editor
        ..addParagraph(initialText: text1)
        ..addParagraph(initialText: text2);

      await editor.startTesting();
      editor.editorState.vimMode = true;

      final selection = Selection.collapsed(Position(path: [1]));
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

      if (Platform.isWindows || Platform.isLinux) {
        expect(
          editor.selection,
          Selection.single(path: [1], startOffset: 0),
        );
      }

      await editor.dispose();
    });
  });
}
