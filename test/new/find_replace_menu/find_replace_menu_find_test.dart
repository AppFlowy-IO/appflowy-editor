import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appflowy_editor/src/editor/find_replace_menu/find_replace_widget.dart';
import 'package:appflowy_editor/appflowy_editor.dart';

import '../infra/testable_editor.dart';

const text = 'Welcome to Appflowy 😁';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('find_replace_menu.dart findMenu', () {
    testWidgets('appears properly', (tester) async {
      await _prepareFindDialog(tester, lines: 3);

      //the prepareFindDialog method only checks if FindMenuWidget is present
      //so here we also check if FindMenuWidget contains TextField
      //and IconButtons or not.
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(IconButton), findsAtLeastNWidgets(4));

      await tester.editor.dispose();
    });

    testWidgets('disappears when close is called', (tester) async {
      await _prepareFindDialog(tester, lines: 3);

      //lets check if find menu disappears if the close button is tapped.
      await tester.tap(find.byKey(const Key('closeButton')));
      await tester.pumpAndSettle();

      expect(find.byType(FindMenuWidget), findsNothing);
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(IconButton), findsNothing);

      await tester.editor.dispose();
    });

    testWidgets('does not highlight anything when empty string searched',
        (tester) async {
      //we expect nothing to be highlighted
      await _prepareFindAndInputPattern(tester, '', true);
    });

    testWidgets('works properly when match is not found', (tester) async {
      //we expect nothing to be highlighted
      await _prepareFindAndInputPattern(tester, 'Flutter', true);
    });

    testWidgets('highlights properly when match is found', (tester) async {
      //we expect something to be highlighted
      await _prepareFindAndInputPattern(tester, 'Welcome', false);
    });

    testWidgets('selects found match', (tester) async {
      const pattern = 'Welcome';

      final editor = tester.editor;
      editor.addParagraphs(3, initialText: text);

      await editor.startTesting();
      await editor.updateSelection(Selection.single(path: [0], startOffset: 0));

      await _pressFindAndReplaceCommand(editor);

      await tester.pumpAndSettle();

      expect(find.byType(FindMenuWidget), findsOneWidget);

      await _enterInputIntoFindDialog(tester, pattern);

      await editor.pressKey(
        key: LogicalKeyboardKey.enter,
      );

      //checking if current selection consists an occurance of matched pattern.
      final selection =
          editor.editorState.service.selectionService.currentSelection.value;

      //we expect the last occurance of the pattern to be found and selected,
      //thus that should be the current selection.
      expect(selection != null, true);
      expect(selection!.start, Position(path: [2], offset: 0));
      expect(selection.end, Position(path: [2], offset: pattern.length));

      await editor.dispose();
    });

    testWidgets('navigating to previous and next matches works',
        (tester) async {
      const pattern = 'Welcome';
      const previousBtnKey = Key('previousMatchButton');
      const nextBtnKey = Key('nextMatchButton');

      final editor = tester.editor;
      editor.addParagraphs(2, initialText: text);

      await editor.startTesting();
      await editor.updateSelection(Selection.single(path: [0], startOffset: 0));

      await _pressFindAndReplaceCommand(editor);

      await tester.pumpAndSettle();

      expect(find.byType(FindMenuWidget), findsOneWidget);

      await _enterInputIntoFindDialog(tester, pattern);

      await editor.pressKey(
        key: LogicalKeyboardKey.enter,
      );

      //checking if current selection consists an occurance of matched pattern.
      var selection =
          editor.editorState.service.selectionService.currentSelection.value;

      //we expect the last occurance of the pattern to be found, thus that should
      //be the current selection.
      expect(selection != null, true);
      expect(selection!.start, Position(path: [1], offset: 0));
      expect(selection.end, Position(path: [1], offset: pattern.length));

      //now pressing the icon button for previous match should select
      //node at path [0].
      await tester.tap(find.byKey(previousBtnKey));
      await tester.pumpAndSettle();

      selection =
          editor.editorState.service.selectionService.currentSelection.value;

      expect(selection != null, true);
      expect(selection!.start, Position(path: [0], offset: 0));
      expect(selection.end, Position(path: [0], offset: pattern.length));

      //now pressing the icon button for previous match should select
      //node at path [1], since there is no node before node at [0].
      await tester.tap(find.byKey(previousBtnKey));
      await tester.pumpAndSettle();

      selection =
          editor.editorState.service.selectionService.currentSelection.value;

      expect(selection != null, true);
      expect(selection!.start, Position(path: [1], offset: 0));
      expect(selection.end, Position(path: [1], offset: pattern.length));

      //now pressing the icon button for next match should select
      //node at path[0], since there is no node after node at [1].
      await tester.tap(find.byKey(nextBtnKey));
      await tester.pumpAndSettle();

      selection =
          editor.editorState.service.selectionService.currentSelection.value;

      expect(selection != null, true);
      expect(selection!.start, Position(path: [0], offset: 0));
      expect(selection.end, Position(path: [0], offset: pattern.length));

      //now pressing the icon button for next match should select
      //node at path [1].
      await tester.tap(find.byKey(nextBtnKey));
      await tester.pumpAndSettle();

      selection =
          editor.editorState.service.selectionService.currentSelection.value;

      expect(selection != null, true);
      expect(selection!.start, Position(path: [1], offset: 0));
      expect(selection.end, Position(path: [1], offset: pattern.length));

      await editor.dispose();
    });

    testWidgets('found matches are unhighlighted when findMenu closed',
        (tester) async {
      const pattern = 'Welcome';
      const closeBtnKey = Key('closeButton');

      final editor = tester.editor;
      editor.addParagraphs(3, initialText: text);

      await editor.startTesting();
      await editor.updateSelection(Selection.single(path: [0], startOffset: 0));

      await _pressFindAndReplaceCommand(editor);

      await tester.pumpAndSettle();

      expect(find.byType(FindMenuWidget), findsOneWidget);

      await _enterInputIntoFindDialog(tester, pattern);

      await editor.pressKey(
        key: LogicalKeyboardKey.enter,
      );

      final selection =
          editor.editorState.service.selectionService.currentSelection.value;
      expect(selection, isNotNull);

      final node = editor.nodeAtPath([2]);
      expect(node, isNotNull);

      //node is highlighted while menu is active
      _checkIfNotHighlighted(node!, selection!, expectedResult: false);

      //presses the close button
      await tester.tap(find.byKey(closeBtnKey));
      await tester.pumpAndSettle();

      //closes the findMenuWidget
      expect(find.byType(FindMenuWidget), findsNothing);

      //we expect that the current selected node is NOT highlighted.
      _checkIfNotHighlighted(node, selection, expectedResult: true);

      await editor.dispose();
    });

    testWidgets('old matches are unhighlighted when new pattern is searched',
        (tester) async {
      const textLine1 = 'Welcome to Appflowy 😁';
      const textLine2 = 'Appflowy is made with Flutter, Rust and ❤️';
      var pattern = 'Welcome';

      final editor = tester.editor
        ..addParagraph(initialText: textLine1)
        ..addParagraph(initialText: textLine2);

      await editor.startTesting();
      await editor.updateSelection(Selection.single(path: [0], startOffset: 0));

      await _pressFindAndReplaceCommand(editor);

      await tester.pumpAndSettle();

      await _enterInputIntoFindDialog(tester, pattern);

      await editor.pressKey(
        key: LogicalKeyboardKey.enter,
      );

      //since node at path [1] does not contain match, we expect it
      //to be not highlighted.
      final selectionAtNode1 = Selection.single(
        path: [1],
        startOffset: 0,
        endOffset: textLine2.length,
      );
      var node = editor.nodeAtPath([1]);
      expect(node, isNotNull);

      //we expect that the current node at path 1 to be NOT highlighted.
      _checkIfNotHighlighted(node!, selectionAtNode1, expectedResult: true);

      //now we will change the pattern to Flutter and search it
      pattern = 'Flutter';
      await _enterInputIntoFindDialog(tester, pattern);

      //finds the pattern Flutter
      await editor.pressKey(
        key: LogicalKeyboardKey.enter,
      );

      //we expect that the current selected node is highlighted.
      _checkIfNotHighlighted(node, selectionAtNode1, expectedResult: false);

      final selectionAtNode0 = Selection.single(
        path: [0],
        startOffset: 0,
        endOffset: textLine1.length,
      );
      node = editor.nodeAtPath([0]);
      expect(node, isNotNull);

      //we expect that the current node at path 0 to be NOT highlighted.
      _checkIfNotHighlighted(node!, selectionAtNode0, expectedResult: true);

      await editor.dispose();
    });
  });
}

Future<void> _prepareFindDialog(
  WidgetTester tester, {
  int lines = 1,
}) async {
  const text = 'Welcome to Appflowy 😁';
  final editor = tester.editor;
  for (var i = 0; i < lines; i++) {
    editor.addParagraph(initialText: text);
  }
  await editor.startTesting();
  await editor.updateSelection(Selection.single(path: [0], startOffset: 0));

  await _pressFindAndReplaceCommand(editor);

  await tester.pumpAndSettle(const Duration(milliseconds: 1000));

  expect(find.byType(FindMenuWidget), findsOneWidget);
}

Future<void> _prepareFindAndInputPattern(
  WidgetTester tester,
  String pattern,
  bool expectedResult,
) async {
  final editor = tester.editor;
  editor.addParagraph(initialText: text);

  await editor.startTesting();
  await editor.updateSelection(Selection.single(path: [0], startOffset: 0));

  await _pressFindAndReplaceCommand(editor);

  await tester.pumpAndSettle();

  expect(find.byType(FindMenuWidget), findsOneWidget);

  await _enterInputIntoFindDialog(tester, pattern);
  //pressing enter should trigger the findAndHighlight method, which
  //will find the pattern inside the editor.
  await editor.pressKey(
    key: LogicalKeyboardKey.enter,
  );

  //since the method will not select anything as searched pattern is
  //empty, the current selection should be equal to previous selection.
  final selection =
      Selection.single(path: [0], startOffset: 0, endOffset: text.length);

  final node = editor.nodeAtPath([0]);
  expect(node, isNotNull);

  _checkIfNotHighlighted(node!, selection, expectedResult: expectedResult);

  await editor.dispose();
}

Future<void> _pressFindAndReplaceCommand(
  TestableEditor editor, {
  bool openReplace = false,
}) async {
  await editor.pressKey(
    key: openReplace ? LogicalKeyboardKey.keyH : LogicalKeyboardKey.keyF,
    isMetaPressed: Platform.isMacOS,
    isControlPressed: !Platform.isMacOS,
  );
}

void _checkIfNotHighlighted(
  Node node,
  Selection selection, {
  bool expectedResult = true,
}) {
  //if the expectedResult is true:
  //we expect that nothing is highlighted in our current document.
  //otherwise: we expect that something is highlighted.
  expect(
    node.allSatisfyInSelection(selection, (delta) {
      return delta.whereType<TextInsert>().every(
            (el) => el.attributes?[AppFlowyRichTextKeys.highlightColor] == null,
          );
    }),
    expectedResult,
  );
}

Future<void> _enterInputIntoFindDialog(
  WidgetTester tester,
  String pattern,
) async {
  const textInputKey = Key('findTextField');
  await tester.tap(find.byKey(textInputKey));
  await tester.enterText(find.byKey(textInputKey), pattern);
  await tester.pumpAndSettle();
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
}
