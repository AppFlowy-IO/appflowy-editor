import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../infra/testable_editor.dart';
import '../../../util/util.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('redo_undo_handler_test.dart', () {
    // TODO: need to test more cases.

    testWidgets('Redo should do nothing if Undo is not yet performed',
        (tester) async {
      await _testRedoWithoutUndo(tester);
    });

    testWidgets('Undo and Redo works properly with text formatting bold',
        (tester) async {
      await _testWithTextFormattingBold(tester);
    });

    testWidgets('Undo and Redo works properly with text formatting italics',
        (tester) async {
      await _testWithTextFormattingItalics(tester);
    });

    testWidgets('Undo and Redo works properly with text formatting underline',
        (tester) async {
      await _testWithTextFormattingUnderline(tester);
    });

    testWidgets('Redo, Undo for backspace key, and selection is downward',
        (tester) async {
      await _testBackspaceUndoRedo(tester, true);
    });

    testWidgets('Redo, Undo for backspace key, and selection is forward',
        (tester) async {
      await _testBackspaceUndoRedo(tester, false);
    });
  });
}

Future<void> _testRedoWithoutUndo(WidgetTester tester) async {
  const text = 'Welcome to Appflowy 😁';
  final editor = tester.editor..addParagraphs(3, initialText: text);
  await editor.startTesting();
  final selection = Selection.single(path: [1], startOffset: 0);
  await editor.updateSelection(selection);

  expect(editor.documentRootLen, 3);

  await _pressRedoCommand(editor);

  expect(editor.documentRootLen, 3);

  await editor.dispose();
}

Future<void> _testWithTextFormattingBold(WidgetTester tester) async {
  const text = 'Welcome to Appflowy 😁';
  final editor = tester.editor..addParagraphs(3, initialText: text);
  await editor.startTesting();

  final node = editor.nodeAtPath([0])!;
  var selection = Selection.single(
    path: [0],
    startOffset: 1,
    endOffset: text.length,
  );
  var result = node.allBold(selection);
  expect(node.delta!.toPlainText(), text);
  expect(result, false);

  final start = Position(path: [0], offset: 0);
  final end = Position(path: [0], offset: text.length);
  selection = Selection(
    start: start,
    end: end,
  );

  await editor.updateSelection(selection);
  await editor.pressKey(
    key: LogicalKeyboardKey.keyB,
    isMetaPressed: Platform.isMacOS,
    isControlPressed: Platform.isWindows || Platform.isLinux,
  );

  selection = Selection.single(
    path: [0],
    startOffset: 1,
    endOffset: text.length,
  );

  result = node.allBold(selection);
  expect(result, true);

  //undo should remove bold style and make it normal.
  await _pressUndoCommand(editor);

  result = node.allBold(selection);
  expect(result, false);

  //redo should make text bold.
  await _pressRedoCommand(editor);

  result = node.allBold(selection);
  expect(result, true);

  await editor.dispose();
}

Future<void> _testWithTextFormattingItalics(WidgetTester tester) async {
  const text = 'Welcome to Appflowy 😁';
  final editor = tester.editor..addParagraphs(3, initialText: text);
  await editor.startTesting();

  final node = editor.nodeAtPath([0])!;
  var allItalics = node.allItalic(
    Selection.single(path: [0], startOffset: 1, endOffset: text.length),
  );

  expect(node.delta!.toPlainText(), text);
  expect(allItalics, false);

  final start = Position(path: [0], offset: 0);
  final end = Position(path: [0], offset: text.length);
  final selection = Selection(
    start: start,
    end: end,
  );

  await editor.updateSelection(selection);

  await editor.pressKey(
    key: LogicalKeyboardKey.keyI,
    isControlPressed: Platform.isWindows || Platform.isLinux,
    isMetaPressed: Platform.isMacOS,
  );

  allItalics = node.allItalic(
    Selection.single(path: [0], startOffset: 1, endOffset: text.length),
  );
  expect(allItalics, true);

  //undo should remove italic style and make it normal.
  await _pressUndoCommand(editor);

  allItalics = node.allItalic(
    Selection.single(path: [0], startOffset: 1, endOffset: text.length),
  );
  expect(allItalics, false);

  //redo should make text italic again.
  await _pressRedoCommand(editor);

  allItalics = node.allItalic(
    Selection.single(path: [0], startOffset: 1, endOffset: text.length),
  );
  expect(allItalics, true);

  await editor.dispose();
}

Future<void> _testWithTextFormattingUnderline(WidgetTester tester) async {
  const text = 'Welcome to Appflowy 😁';
  final editor = tester.editor..addParagraphs(3, initialText: text);
  await editor.startTesting();

  final node = editor.nodeAtPath([0])!;
  var allUnderline = node.allUnderline(
    Selection.single(path: [0], startOffset: 1, endOffset: text.length),
  );

  expect(node.delta!.toPlainText(), text);
  expect(allUnderline, false);

  final start = Position(path: [0], offset: 0);
  final end = Position(path: [0], offset: text.length);
  final selection = Selection(
    start: start,
    end: end,
  );

  await editor.updateSelection(selection);

  await editor.pressKey(
    key: LogicalKeyboardKey.keyU,
    isControlPressed: Platform.isWindows || Platform.isLinux,
    isMetaPressed: Platform.isMacOS,
  );

  allUnderline = node.allUnderline(
    Selection.single(path: [0], startOffset: 1, endOffset: text.length),
  );
  expect(allUnderline, true);

  //undo should remove underline style and make it normal.
  await _pressUndoCommand(editor);

  allUnderline = node.allUnderline(
    Selection.single(path: [0], startOffset: 1, endOffset: text.length),
  );
  expect(allUnderline, false);

  //redo should make text underline.
  await _pressRedoCommand(editor);

  allUnderline = node.allUnderline(
    Selection.single(path: [0], startOffset: 1, endOffset: text.length),
  );
  expect(allUnderline, true);

  await editor.dispose();
}

Future<void> _testBackspaceUndoRedo(
  WidgetTester tester,
  bool isDownwardSelection,
) async {
  const text = 'Welcome to Appflowy 😁';
  final editor = tester.editor..addParagraphs(3, initialText: text);
  await editor.startTesting();

  final start = Position(path: [0], offset: text.length);
  final end = Position(path: [1], offset: text.length);
  final selection = Selection(
    start: isDownwardSelection ? start : end,
    end: isDownwardSelection ? end : start,
  );
  await editor.updateSelection(selection);
  await editor.pressKey(key: LogicalKeyboardKey.backspace);
  expect(editor.documentRootLen, 2);

  await _pressUndoCommand(editor);

  expect(editor.documentRootLen, 3);
  expect(editor.nodeAtPath([1])!.delta!.toPlainText(), text);
  expect(editor.selection, selection);

  await _pressRedoCommand(editor);

  expect(editor.documentRootLen, 2);

  await editor.dispose();
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
