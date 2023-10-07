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

    // Before
    // Welcome to AppFlowy 0| <- cursor here
    //  Welcome to AppFlowy 0 - 1
    //
    // press enter key at the cursor position
    // and then, press tab key to indent the empty line
    // After
    // Welcome to AppFlowy 0
    //  | <- cursor here
    //    Welcome to AppFlowy 0 - 1
    //
    // execute undo command twice
    //
    // then it should be like this
    // Welcome to AppFlowy 0| <- cursor here
    //  Welcome to AppFlowy 0 - 1
    //
    // after that, execute redo command twice
    //
    // Welcome to AppFlowy 0
    //  | <- cursor here
    //    Welcome to AppFlowy 0 - 1
    testWidgets('Undo the nested list', (tester) async {
      const text0 = 'Welcome to AppFlowy 0';
      const text01 = 'Welcome to AppFlowy 0 - 1';

      // Welcome to AppFlowy 0
      // |Welcome to AppFlowy 0 - 1
      final editor = tester.editor
        ..addParagraph(initialText: text0)
        ..addParagraph(initialText: text01);

      await editor.startTesting();
      await editor.updateSelection(
        Selection.collapsed(Position(path: [1], offset: 0)),
      );
      await editor.pressKey(key: LogicalKeyboardKey.tab);

      // Welcome to AppFlowy 0|
      //  Welcome to AppFlowy 0 - 1
      await editor.updateSelection(
        Selection.collapsed(Position(path: [0], offset: text0.length)),
      );
      await editor.pressKey(character: '\n');
      await editor.pressKey(key: LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      expect(editor.nodeAtPath([0])!.delta!.toPlainText(), text0);
      expect(editor.nodeAtPath([0, 0])!.delta!.toPlainText(), isEmpty);
      expect(editor.nodeAtPath([0, 0, 0])!.delta!.toPlainText(), text01);

      // first undo
      await _pressUndoCommand(editor);
      expect(editor.nodeAtPath([0])!.delta!.toPlainText(), text0);
      expect(editor.nodeAtPath([1])!.delta!.toPlainText(), isEmpty);
      expect(editor.nodeAtPath([1, 0])!.delta!.toPlainText(), text01);

      // second undo
      await _pressUndoCommand(editor);
      expect(editor.nodeAtPath([0])!.delta!.toPlainText(), text0);
      expect(editor.nodeAtPath([0, 0])!.delta!.toPlainText(), text01);

      // first redo
      await _pressRedoCommand(editor);
      expect(editor.nodeAtPath([0])!.delta!.toPlainText(), text0);
      expect(editor.nodeAtPath([0])!.children, isEmpty);
      expect(editor.nodeAtPath([1])!.delta!.toPlainText(), isEmpty);
      expect(editor.nodeAtPath([1, 0])!.delta!.toPlainText(), text01);

      // second redo
      await _pressRedoCommand(editor);
      expect(editor.nodeAtPath([0])!.delta!.toPlainText(), text0);
      expect(editor.nodeAtPath([1])!.delta!.toPlainText(), isEmpty);
      expect(editor.nodeAtPath([1, 0])!.delta!.toPlainText(), text01);

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
