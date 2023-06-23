import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../infra/testable_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('markdown_commands.dart', () {
    testWidgets('Presses Command + B to update text style', (tester) async {
      await _testUpdateTextStyleByCommandX(
        tester,
        BuiltInAttributeKey.bold,
        true,
        LogicalKeyboardKey.keyB,
      );
    });

    testWidgets('Presses Command + I to update text style', (tester) async {
      await _testUpdateTextStyleByCommandX(
        tester,
        BuiltInAttributeKey.italic,
        true,
        LogicalKeyboardKey.keyI,
      );
    });

    testWidgets('Presses Command + U to update text style', (tester) async {
      await _testUpdateTextStyleByCommandX(
        tester,
        BuiltInAttributeKey.underline,
        true,
        LogicalKeyboardKey.keyU,
      );
    });

    testWidgets('Presses Command + Shift + S to update text style',
        (tester) async {
      await _testUpdateTextStyleByCommandX(
        tester,
        BuiltInAttributeKey.strikethrough,
        true,
        LogicalKeyboardKey.keyS,
      );
    });

    testWidgets('Presses Command + E to update text style', (tester) async {
      await _testUpdateTextStyleByCommandX(
        tester,
        BuiltInAttributeKey.code,
        true,
        LogicalKeyboardKey.keyE,
      );
    });
  });
}

Future<void> _testUpdateTextStyleByCommandX(
  WidgetTester tester,
  String matchStyle,
  dynamic matchValue,
  LogicalKeyboardKey key,
) async {
  final isShiftPressed =
      key == LogicalKeyboardKey.keyS || key == LogicalKeyboardKey.keyH;
  const text = 'Welcome to Appflowy 😁';
  final editor = tester.editor..addParagraphs(3, initialText: text);
  await editor.startTesting();

  var selection = Selection.single(
    path: [1],
    startOffset: 2,
    endOffset: text.length - 2,
  );
  await editor.updateSelection(selection);
  await editor.pressKey(
    key: key,
    isShiftPressed: isShiftPressed,
    isMetaPressed: Platform.isMacOS,
    isControlPressed: Platform.isWindows || Platform.isLinux,
  );

  var node = editor.nodeAtPath([1]);
  expect(
    node?.allSatisfyInSelection(selection, (delta) {
      return delta
          .whereType<TextInsert>()
          .every((element) => element.attributes?[matchStyle] == matchValue);
    }),
    true,
  );

  selection = Selection.single(
    path: [1],
    startOffset: 0,
    endOffset: text.length,
  );
  await editor.updateSelection(selection);
  await editor.pressKey(
    key: key,
    isShiftPressed: isShiftPressed,
    isMetaPressed: Platform.isMacOS,
    isControlPressed: Platform.isWindows || Platform.isLinux,
  );
  node = editor.nodeAtPath([1]);
  expect(
    node?.allSatisfyInSelection(selection, (delta) {
      return delta
          .whereType<TextInsert>()
          .every((element) => element.attributes?[matchStyle] == matchValue);
    }),
    true,
  );

  // clear the style
  await editor.updateSelection(selection);
  await editor.pressKey(
    key: key,
    isShiftPressed: isShiftPressed,
    isMetaPressed: Platform.isMacOS,
    isControlPressed: Platform.isWindows || Platform.isLinux,
  );
  node = editor.nodeAtPath([1]);
  expect(
    node?.allSatisfyInSelection(selection, (delta) {
      return delta
          .whereType<TextInsert>()
          .every((element) => element.attributes?[matchStyle] != matchValue);
    }),
    true,
  );
  selection = Selection(
    start: Position(path: [0], offset: 0),
    end: Position(path: [2], offset: text.length),
  );
  await editor.updateSelection(selection);
  await editor.pressKey(
    key: key,
    isShiftPressed: isShiftPressed,
    isMetaPressed: Platform.isMacOS,
    isControlPressed: Platform.isWindows || Platform.isLinux,
  );
  var nodes = editor.editorState.getNodesInSelection(selection);
  expect(nodes.length, 3);
  for (final node in nodes) {
    expect(
      node.allSatisfyInSelection(selection, (delta) {
        return delta
            .whereType<TextInsert>()
            .every((element) => element.attributes?[matchStyle] == matchValue);
      }),
      true,
    );
  }

  await editor.updateSelection(selection);
  await editor.pressKey(
    key: key,
    isShiftPressed: isShiftPressed,
    isMetaPressed: Platform.isMacOS,
    isControlPressed: Platform.isWindows || Platform.isLinux,
  );
  nodes = editor.editorState.getNodesInSelection(selection);
  expect(nodes.length, 3);
  for (final node in nodes) {
    expect(
      node.allSatisfyInSelection(selection, (delta) {
        return delta
            .whereType<TextInsert>()
            .every((element) => element.attributes?[matchStyle] != matchValue);
      }),
      true,
    );
  }

  await editor.dispose();
}
