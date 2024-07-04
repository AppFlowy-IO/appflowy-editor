import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../infra/testable_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('toggle_color_commands.dart', () {
    testWidgets('Presses Command + Shift + H to update text style - highlight',
        (tester) async {
      await _testUpdateTextColorByCommandX(
        tester,
        AppFlowyRichTextKeys.backgroundColor,
        LogicalKeyboardKey.keyH,
      );
    });
  });
}

Future<void> _testUpdateTextColorByCommandX(
  WidgetTester tester,
  String matchStyle,
  LogicalKeyboardKey key,
) async {
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
    isShiftPressed: true,
    isMetaPressed: Platform.isMacOS,
    isControlPressed: Platform.isWindows || Platform.isLinux,
  );
  var node = editor.nodeAtPath([1]);
  expect(
    node?.allSatisfyInSelection(selection, (delta) {
      return delta
          .whereType<TextInsert>()
          .every((element) => element.attributes?[matchStyle] != null);
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
    isShiftPressed: true,
    isMetaPressed: Platform.isMacOS,
    isControlPressed: Platform.isWindows || Platform.isLinux,
  );
  node = editor.nodeAtPath([1]);
  expect(
    node?.allSatisfyInSelection(selection, (delta) {
      return delta
          .whereType<TextInsert>()
          .every((element) => element.attributes?[matchStyle] != null);
    }),
    true,
  );

  // clear the style
  await editor.updateSelection(selection);
  await editor.pressKey(
    key: key,
    isShiftPressed: true,
    isMetaPressed: Platform.isMacOS,
    isControlPressed: Platform.isWindows || Platform.isLinux,
  );
  node = editor.nodeAtPath([1]);
  expect(
    node?.allSatisfyInSelection(selection, (delta) {
      return delta
          .whereType<TextInsert>()
          .every((element) => element.attributes?[matchStyle] == null);
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
    isShiftPressed: true,
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
            .every((element) => element.attributes?[matchStyle] != null);
      }),
      true,
    );
  }

  await editor.updateSelection(selection);
  await editor.pressKey(
    key: key,
    isShiftPressed: true,
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
            .every((element) => element.attributes?[matchStyle] == null);
      }),
      true,
    );
  }

  await editor.dispose();
}
