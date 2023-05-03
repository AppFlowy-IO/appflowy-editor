import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/render/link_menu/link_menu.dart';
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

    // TODO: @yijing refactor this test.
    // testWidgets('Presses Command + Shift + H to update text style',
    //     (tester) async {
    //   // FIXME: customize the highlight color instead of using magic number.
    //   await _testUpdateTextStyleByCommandX(
    //     tester,
    //     BuiltInAttributeKey.backgroundColor,
    //     '0x6000BCF0',
    //     LogicalKeyboardKey.keyH,
    //   );
    // });

    // testWidgets('Presses Command + K to trigger link menu', (tester) async {
    //   await _testLinkMenuInSingleTextSelection(tester);
    // });

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

Future<void> _testLinkMenuInSingleTextSelection(WidgetTester tester) async {
  const link = 'appflowy.io';
  const text = 'Welcome to Appflowy 😁';
  final editor = tester.editor..addParagraphs(3, initialText: text);
  await editor.startTesting();

  final selection =
      Selection.single(path: [1], startOffset: 0, endOffset: text.length);
  await editor.updateSelection(selection);

  // show toolbar
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
  expect(find.byType(ToolbarWidget), findsOneWidget);

  // trigger the link menu
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
}
