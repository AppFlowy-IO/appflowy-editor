import 'dart:io';

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

  const text = 'Welcome to AppFlowy Editor 🔥!';

  group('undo and redo commands - widget test', () {
    // Before
    // |Welcome| to AppFlowy Editor 🔥!
    // After Undo
    // | to AppFlowy Editor 🔥!
    // After Redo
    // |Welcome| to AppFlowy Editor 🔥!
    testWidgets('Delete text and then perform undo & redo', (tester) async {
      final editor = tester.editor
        ..addParagraph(
          initialText: text,
        );
      await editor.startTesting();

      // |Welcome| to AppFlowy Editor 🔥!
      const welcome = 'Welcome';
      final selection = Selection.single(
        path: [0],
        startOffset: 0,
        endOffset: welcome.length,
      );
      await editor.updateSelection(selection);

      await simulateKeyDownEvent(LogicalKeyboardKey.backspace);
      await tester.pumpAndSettle();

      // the first node should be deleted.
      expect(
        editor.nodeAtPath([0])?.delta?.toPlainText(),
        text.substring(welcome.length),
      );

      //pressing undo shortcut should bring back deleted text.
      await _pressUndoCommand(editor);

      expect(
        editor.nodeAtPath([0])?.delta?.toPlainText(),
        text,
      );

      //redo should delete the text again.
      await _pressRedoCommand(editor);

      expect(
        editor.nodeAtPath([0])?.delta?.toPlainText(),
        text.substring(welcome.length),
      );

      await editor.dispose();
    });

    testWidgets('Delete a non-text node and then perform undo and redo',
        (tester) async {
      const kParagraphType = "paragraph";
      const kDividerType = "divider";

      final editor = tester.editor
        ..addParagraph(initialText: text)
        ..addNode(dividerNode())
        ..addParagraph(initialText: text);

      await editor.startTesting();

      await _selectNodeAtPathAndDelete(editor);
      await tester.pumpAndSettle();

      expect(
        editor.nodeAtPath([1])?.type,
        kParagraphType,
      );

      //pressing undo should add the divider back to the editor
      await _pressUndoCommand(editor);

      expect(
        editor.nodeAtPath([1])?.type,
        kDividerType,
      );

      //redo should remove the divider again.
      await _pressRedoCommand(editor);

      expect(
        editor.nodeAtPath([1])?.type,
        kParagraphType,
      );

      await editor.dispose();
    });
  });
}

Future<void> _pressUndoCommand(TestableEditor editor) async {
  await editor.pressKey(
    key: LogicalKeyboardKey.keyZ,
    isMetaPressed: Platform.isMacOS,
    isControlPressed: Platform.isWindows || Platform.isLinux,
  );
}

Future<void> _pressRedoCommand(TestableEditor editor) async {
  await editor.pressKey(
    key: Platform.isMacOS ? LogicalKeyboardKey.keyZ : LogicalKeyboardKey.keyY,
    isMetaPressed: Platform.isMacOS,
    isShiftPressed: Platform.isMacOS,
    isControlPressed: !Platform.isMacOS,
  );
}

Future<void> _selectNodeAtPathAndDelete(TestableEditor editor) async {
  final selection = Selection.single(
    path: [1],
    startOffset: 0,
    endOffset: 1,
  );
  await editor.updateSelection(selection);

  await simulateKeyDownEvent(LogicalKeyboardKey.backspace);
}
