import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/toolbar/items/link/link_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../infra/testable_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('show_link_menu_command.dart', () {
    testWidgets('Presses Command + K to trigger link menu', (tester) async {
      await _testLinkMenuInSingleTextSelection(tester);
    });
  });
}

Future<void> _testLinkMenuInSingleTextSelection(WidgetTester tester) async {
  const link = 'appflowy.io';
  const text = 'Welcome to Appflowy 😁';

  final editor = tester.editor..addParagraphs(3, initialText: text);
  await editor.startTesting();
  final scrollController = ScrollController();

  final editorWithToolbar = FloatingToolbar(
    items: [
      paragraphItem,
      ...headingItems,
      placeholderItem,
      ...markdownFormatItems,
      placeholderItem,
      quoteItem,
      bulletedListItem,
      numberedListItem,
      placeholderItem,
      linkItem,
      textColorItem,
      highlightColorItem,
    ],
    editorState: editor.editorState,
    scrollController: scrollController,
    child: AppFlowyEditor.standard(editorState: editor.editorState),
  );

  await tester.pumpWidget(
    MaterialApp(
      home: Material(
        child: editorWithToolbar,
      ),
    ),
  );

  final selection =
      Selection.single(path: [1], startOffset: 0, endOffset: text.length);
  await editor.updateSelection(selection);

  // show toolbar
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
  expect(find.byType(FloatingToolbar), findsOneWidget);

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
  await tester.testTextInput.receiveAction(TextInputAction.send);
  await tester.pumpAndSettle(const Duration(milliseconds: 500));

  // After link is added, the link menu should be dismissed
  expect(find.byType(LinkMenu), findsNothing);

  // Check if the link is added
  final nodes = editor.editorState.getNodesInSelection(selection);
  expect(
    nodes.allSatisfyInSelection(selection, (delta) {
      return delta.whereType<TextInsert>().every(
            (element) => element.attributes?[BuiltInAttributeKey.href] == link,
          );
    }),
    true,
  );

  // Trigger the link menu again
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

  // Check if the link menu is shown
  expect(find.byType(LinkMenu), findsOneWidget);
  expect(
    find.text(link, findRichText: true, skipOffstage: false),
    findsOneWidget,
  );

  // Copy link
  final copyLink = find.text('Copy link');
  expect(copyLink, findsOneWidget);
  await tester.tap(copyLink);
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
  expect(find.byType(LinkMenu), findsNothing);

  await tester.pumpAndSettle();

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
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
  expect(find.byType(LinkMenu), findsNothing);

  await tester.pumpAndSettle(const Duration(milliseconds: 500));

  // Check if the link is removed
  expect(
    nodes.allSatisfyInSelection(selection, (delta) {
      return delta.whereType<TextInsert>().every(
            (element) => element.attributes?[BuiltInAttributeKey.href] == link,
          );
    }),
    false,
  );
}
