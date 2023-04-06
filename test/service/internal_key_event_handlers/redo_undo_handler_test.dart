import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/extensions/text_node_extensions.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../infra/test_editor.dart';

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
  final editor = tester.editor
    ..insertTextNode(text)
    ..insertTextNode(text)
    ..insertTextNode(text);
  await editor.startTesting();
  final selection = Selection.single(path: [1], startOffset: 0);
  await editor.updateSelection(selection);

  expect(editor.documentLength, 3);

  if (Platform.isWindows || Platform.isLinux) {
    await editor.pressLogicKey(
      key: LogicalKeyboardKey.keyZ,
      isControlPressed: true,
      isShiftPressed: true,
    );
  } else {
    await editor.pressLogicKey(
      key: LogicalKeyboardKey.keyZ,
      isMetaPressed: true,
      isShiftPressed: true,
    );
  }

  expect(editor.documentLength, 3);
}

Future<void> _testWithTextFormattingBold(WidgetTester tester) async {
  const text = 'Welcome to Appflowy 😁';
  final editor = tester.editor
    ..insertTextNode(text)
    ..insertTextNode(text)
    ..insertTextNode(text);
  await editor.startTesting();

  final textNode = editor.nodeAtPath([0]) as TextNode;
  var allBold = textNode.allSatisfyBoldInSelection(
      Selection.single(path: [0], startOffset: 1, endOffset: text.length));

  expect(textNode.toPlainText(), text);
  expect(allBold, false);

  final start = Position(path: [0], offset: 0);
  final end = Position(path: [0], offset: text.length);
  final selection = Selection(
    start: start,
    end: end,
  );

  await editor.updateSelection(selection);

  if (Platform.isMacOS) {
    await editor.pressLogicKey(
      key: LogicalKeyboardKey.keyB,
      isMetaPressed: true,
    );
  } else {
    await editor.pressLogicKey(
      key: LogicalKeyboardKey.keyB,
      isControlPressed: true,
    );
  }

  allBold = textNode.allSatisfyBoldInSelection(
      Selection.single(path: [0], startOffset: 1, endOffset: text.length));
  expect(allBold, true);

  //undo should remove bold style and make it normal.
  if (Platform.isMacOS) {
    await editor.pressLogicKey(
      key: LogicalKeyboardKey.keyZ,
      isMetaPressed: true,
    );
  } else {
    await editor.pressLogicKey(
      key: LogicalKeyboardKey.keyZ,
      isControlPressed: true,
    );
  }

  allBold = textNode.allSatisfyBoldInSelection(
      Selection.single(path: [0], startOffset: 1, endOffset: text.length));
  expect(allBold, false);

  //redo should make text bold.
  if (Platform.isMacOS) {
    await editor.pressLogicKey(
      key: LogicalKeyboardKey.keyZ,
      isMetaPressed: true,
      isShiftPressed: true,
    );
  } else {
    await editor.pressLogicKey(
      key: LogicalKeyboardKey.keyZ,
      isControlPressed: true,
      isShiftPressed: true,
    );
  }

  allBold = textNode.allSatisfyBoldInSelection(
      Selection.single(path: [0], startOffset: 1, endOffset: text.length));
  expect(allBold, true);
}

Future<void> _testWithTextFormattingItalics(WidgetTester tester) async {
  const text = 'Welcome to Appflowy 😁';
  final editor = tester.editor
    ..insertTextNode(text)
    ..insertTextNode(text)
    ..insertTextNode(text);
  await editor.startTesting();

  final textNode = editor.nodeAtPath([0]) as TextNode;
  var allItalics = textNode.allSatisfyItalicInSelection(
      Selection.single(path: [0], startOffset: 1, endOffset: text.length));

  expect(textNode.toPlainText(), text);
  expect(allItalics, false);

  final start = Position(path: [0], offset: 0);
  final end = Position(path: [0], offset: text.length);
  final selection = Selection(
    start: start,
    end: end,
  );

  await editor.updateSelection(selection);

  if (Platform.isMacOS) {
    await editor.pressLogicKey(
      key: LogicalKeyboardKey.keyI,
      isMetaPressed: true,
    );
  } else {
    await editor.pressLogicKey(
      key: LogicalKeyboardKey.keyI,
      isControlPressed: true,
    );
  }

  allItalics = textNode.allSatisfyItalicInSelection(
      Selection.single(path: [0], startOffset: 1, endOffset: text.length));
  expect(allItalics, true);

  //undo should remove italic style and make it normal.
  if (Platform.isMacOS) {
    await editor.pressLogicKey(
      key: LogicalKeyboardKey.keyZ,
      isMetaPressed: true,
    );
  } else {
    await editor.pressLogicKey(
      key: LogicalKeyboardKey.keyZ,
      isControlPressed: true,
    );
  }

  allItalics = textNode.allSatisfyItalicInSelection(
      Selection.single(path: [0], startOffset: 1, endOffset: text.length));
  expect(allItalics, false);

  //redo should make text italic again.
  if (Platform.isMacOS) {
    await editor.pressLogicKey(
      key: LogicalKeyboardKey.keyZ,
      isMetaPressed: true,
      isShiftPressed: true,
    );
  } else {
    await editor.pressLogicKey(
      key: LogicalKeyboardKey.keyZ,
      isControlPressed: true,
      isShiftPressed: true,
    );
  }

  allItalics = textNode.allSatisfyItalicInSelection(
      Selection.single(path: [0], startOffset: 1, endOffset: text.length));
  expect(allItalics, true);
}

Future<void> _testWithTextFormattingUnderline(WidgetTester tester) async {
  const text = 'Welcome to Appflowy 😁';
  final editor = tester.editor
    ..insertTextNode(text)
    ..insertTextNode(text)
    ..insertTextNode(text);
  await editor.startTesting();

  final textNode = editor.nodeAtPath([0]) as TextNode;
  var allUnderline = textNode.allSatisfyUnderlineInSelection(
      Selection.single(path: [0], startOffset: 1, endOffset: text.length));

  expect(textNode.toPlainText(), text);
  expect(allUnderline, false);

  final start = Position(path: [0], offset: 0);
  final end = Position(path: [0], offset: text.length);
  final selection = Selection(
    start: start,
    end: end,
  );

  await editor.updateSelection(selection);

  if (Platform.isMacOS) {
    await editor.pressLogicKey(
      key: LogicalKeyboardKey.keyU,
      isMetaPressed: true,
    );
  } else {
    await editor.pressLogicKey(
      key: LogicalKeyboardKey.keyU,
      isControlPressed: true,
    );
  }

  allUnderline = textNode.allSatisfyUnderlineInSelection(
      Selection.single(path: [0], startOffset: 1, endOffset: text.length));
  expect(allUnderline, true);

  //undo should remove bold style and make it normal.
  if (Platform.isMacOS) {
    await editor.pressLogicKey(
      key: LogicalKeyboardKey.keyZ,
      isMetaPressed: true,
    );
  } else {
    await editor.pressLogicKey(
      key: LogicalKeyboardKey.keyZ,
      isControlPressed: true,
    );
  }

  allUnderline = textNode.allSatisfyUnderlineInSelection(
      Selection.single(path: [0], startOffset: 1, endOffset: text.length));
  expect(allUnderline, false);

  //redo should make text bold.
  if (Platform.isMacOS) {
    await editor.pressLogicKey(
      key: LogicalKeyboardKey.keyZ,
      isMetaPressed: true,
      isShiftPressed: true,
    );
  } else {
    await editor.pressLogicKey(
      key: LogicalKeyboardKey.keyZ,
      isControlPressed: true,
      isShiftPressed: true,
    );
  }

  allUnderline = textNode.allSatisfyUnderlineInSelection(
      Selection.single(path: [0], startOffset: 1, endOffset: text.length));
  expect(allUnderline, true);
}

Future<void> _testBackspaceUndoRedo(
    WidgetTester tester, bool isDownwardSelection) async {
  const text = 'Welcome to Appflowy 😁';
  final editor = tester.editor
    ..insertTextNode(text)
    ..insertTextNode(text)
    ..insertTextNode(text);
  await editor.startTesting();

  final start = Position(path: [0], offset: text.length);
  final end = Position(path: [1], offset: text.length);
  final selection = Selection(
    start: isDownwardSelection ? start : end,
    end: isDownwardSelection ? end : start,
  );
  await editor.updateSelection(selection);
  await editor.pressLogicKey(key: LogicalKeyboardKey.backspace);
  expect(editor.documentLength, 2);

  if (Platform.isWindows || Platform.isLinux) {
    await editor.pressLogicKey(
      key: LogicalKeyboardKey.keyZ,
      isControlPressed: true,
    );
  } else {
    await editor.pressLogicKey(
      key: LogicalKeyboardKey.keyZ,
      isMetaPressed: true,
    );
  }

  expect(editor.documentLength, 3);
  expect((editor.nodeAtPath([1]) as TextNode).toPlainText(), text);
  expect(editor.documentSelection, selection);

  if (Platform.isWindows || Platform.isLinux) {
    await editor.pressLogicKey(
      key: LogicalKeyboardKey.keyZ,
      isControlPressed: true,
      isShiftPressed: true,
    );
  } else {
    await editor.pressLogicKey(
      key: LogicalKeyboardKey.keyZ,
      isMetaPressed: true,
      isShiftPressed: true,
    );
  }

  expect(editor.documentLength, 2);
}
