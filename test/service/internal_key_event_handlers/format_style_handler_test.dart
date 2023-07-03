import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/toolbar/desktop/items/link/link_menu.dart';

import 'package:appflowy_editor/src/render/toolbar/toolbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../new/infra/testable_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('format_style_handler.dart', () {
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

  var selection =
      Selection.single(path: [1], startOffset: 2, endOffset: text.length - 2);
  await editor.updateSelection(selection);
  if (Platform.isWindows || Platform.isLinux) {
    await editor.pressKey(
      key: key,
      isShiftPressed: isShiftPressed,
      isControlPressed: true,
    );
  } else {
    await editor.pressKey(
      key: key,
      isShiftPressed: isShiftPressed,
      isMetaPressed: true,
    );
  }
  Node? node = editor.nodeAtPath([1]);
  expect(
    node?.allSatisfyInSelection(selection, (delta) {
      return delta
          .everyAttributes((element) => element[matchStyle] == matchValue);
    }),
    true,
  );

  selection =
      Selection.single(path: [1], startOffset: 0, endOffset: text.length);
  await editor.updateSelection(selection);
  if (Platform.isWindows || Platform.isLinux) {
    await editor.pressKey(
      key: key,
      isShiftPressed: isShiftPressed,
      isControlPressed: true,
    );
  } else {
    await editor.pressKey(
      key: key,
      isShiftPressed: isShiftPressed,
      isMetaPressed: true,
    );
  }
  node = editor.nodeAtPath([1]);
  expect(
    node?.allSatisfyInSelection(selection, (delta) {
      return delta
          .everyAttributes((element) => element[matchStyle] == matchValue);
    }),
    true,
  );

  await editor.updateSelection(selection);
  if (Platform.isWindows || Platform.isLinux) {
    await editor.pressKey(
      key: key,
      isShiftPressed: isShiftPressed,
      isControlPressed: true,
    );
  } else {
    await editor.pressKey(
      key: key,
      isShiftPressed: isShiftPressed,
      isMetaPressed: true,
    );
  }
  node = editor.nodeAtPath([1]);
  expect(
    node?.allSatisfyInSelection(selection, (delta) {
      return delta
          .everyAttributes((element) => element[matchStyle] == matchValue);
    }),
    false,
  );

  selection = Selection(
    start: Position(path: [0], offset: 0),
    end: Position(path: [2], offset: text.length),
  );
  await editor.updateSelection(selection);
  if (Platform.isWindows || Platform.isLinux) {
    await editor.pressKey(
      key: key,
      isShiftPressed: isShiftPressed,
      isControlPressed: true,
    );
  } else {
    await editor.pressKey(
      key: key,
      isShiftPressed: isShiftPressed,
      isMetaPressed: true,
    );
  }
  var nodes = editor.editorState.service.selectionService.currentSelectedNodes;
  expect(nodes.length, 3);
  for (final node in nodes) {
    expect(
      node.allSatisfyInSelection(
          Selection.single(
            path: node.path,
            startOffset: 0,
            endOffset: text.length,
          ), (delta) {
        return delta
            .everyAttributes((element) => element[matchStyle] == matchValue);
      }),
      true,
    );
  }

  await editor.updateSelection(selection);

  if (Platform.isWindows || Platform.isLinux) {
    await editor.pressKey(
      key: key,
      isShiftPressed: isShiftPressed,
      isControlPressed: true,
    );
  } else {
    await editor.pressKey(
      key: key,
      isShiftPressed: isShiftPressed,
      isMetaPressed: true,
    );
  }
  nodes = editor.editorState.service.selectionService.currentSelectedNodes;
  expect(nodes.length, 3);
  for (final node in nodes) {
    expect(
      node.allSatisfyInSelection(
          Selection.single(
            path: node.path,
            startOffset: 0,
            endOffset: text.length,
          ), (delta) {
        return delta
            .everyAttributes((element) => element[matchStyle] == matchValue);
      }),
      false,
    );
  }

  await editor.dispose();
}

Future<void> _testLinkMenuInSingleTextSelection(WidgetTester tester) async {
  const link = 'appflowy.io';
  const text = 'Welcome to Appflowy 😁';
  final editor = tester.editor..addParagraphs(3, initialText: text);
  await editor.startTesting();

// selection is collapsed
  final emptySelection = Selection.single(
    path: [0],
    startOffset: 7,
  );
  await editor.updateSelection(emptySelection);

  // Link dialog should not be visible when selection is null or collapsed
  await editor.pressKey(
    key: LogicalKeyboardKey.keyK,
    isControlPressed: !Platform.isMacOS,
    isMetaPressed: Platform.isMacOS,
  );
  expect(find.byType(LinkMenu), findsNothing);

// selection is not null
  final selection = Selection.single(
    path: [1],
    startOffset: 0,
    endOffset: text.length,
  );
  await editor.updateSelection(selection);

  // show toolbar
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
  expect(find.byType(ToolbarWidget), findsOneWidget);

  // trigger the link menu
  await editor.pressKey(
    key: LogicalKeyboardKey.keyK,
    isControlPressed: !Platform.isMacOS,
    isMetaPressed: Platform.isMacOS,
  );

  expect(find.byType(LinkMenu), findsOneWidget);

  await tester.enterText(find.byType(TextField), link);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();

  expect(find.byType(LinkMenu), findsNothing);

  final node = editor.nodeAtPath([1]) as TextNode;
  expect(
    node.allSatisfyInSelection(
      selection,
      BuiltInAttributeKey.href,
      (value) => value == link,
    ),
    true,
  );

  await editor.updateSelection(selection);
  await editor.pressKey(
    key: LogicalKeyboardKey.keyK,
    isControlPressed: !Platform.isMacOS,
    isMetaPressed: Platform.isMacOS,
  );
  expect(find.byType(LinkMenu), findsOneWidget);
  expect(
    find.text(link, findRichText: true, skipOffstage: false),
    findsOneWidget,
  );

  // Copy link
  final copyLink = find.text('Copy link');
  expect(copyLink, findsOneWidget);
  await tester.tap(copyLink);
  await tester.pumpAndSettle();
  expect(find.byType(LinkMenu), findsNothing);

  // Remove link
  if (Platform.isWindows || Platform.isLinux) {
    await editor.pressKey(
      key: LogicalKeyboardKey.keyK,
      isControlPressed: true,
    );
  } else {
    await editor.pressKey(
      key: LogicalKeyboardKey.keyK,
      isMetaPressed: true,
    );
  }
  final removeLink = find.text('Remove link');
  expect(removeLink, findsOneWidget);
  await tester.tap(removeLink);
  await tester.pumpAndSettle();
  expect(find.byType(LinkMenu), findsNothing);

  expect(
    node.allSatisfyInSelection(
      selection,
      BuiltInAttributeKey.href,
      (value) => value == link,
    ),
    false,
  );

  await editor.dispose();
}
