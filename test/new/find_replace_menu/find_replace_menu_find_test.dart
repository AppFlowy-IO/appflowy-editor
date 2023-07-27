import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appflowy_editor/src/editor/find_replace_menu/find_replace_widget.dart';
import 'package:appflowy_editor/appflowy_editor.dart';

import '../infra/testable_editor.dart';
import 'find_replace_menu_utils.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('find_replace_menu.dart findMenu', () {
    testWidgets('appears properly', (tester) async {
      await prepareFindAndReplaceDialog(tester);

      //the prepareFindDialog method only checks if FindMenuWidget is present
      //so here we also check if FindMenuWidget contains TextField
      //and IconButtons or not.
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(IconButton), findsAtLeastNWidgets(4));

      await tester.editor.dispose();
    });

    testWidgets('disappears when close is called', (tester) async {
      await prepareFindAndReplaceDialog(tester);

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

      await pressFindAndReplaceCommand(editor);

      await tester.pumpAndSettle();

      expect(find.byType(FindMenuWidget), findsOneWidget);

      await enterInputIntoFindDialog(tester, pattern);

      //checking if current selection consists an occurance of matched pattern.
      final selection =
          editor.editorState.service.selectionService.currentSelection.value;

      //we expect the second occurance of the pattern to be found and selected,
      //this is because we send a testTextInput.receiveAction(TextInputAction.done)
      //event during submitting our text input, thus the second match is selected.
      expect(selection != null, true);
      expect(selection!.start, Position(path: [1], offset: 0));
      expect(selection.end, Position(path: [1], offset: pattern.length));

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

      await pressFindAndReplaceCommand(editor);

      await tester.pumpAndSettle();

      expect(find.byType(FindMenuWidget), findsOneWidget);

      await enterInputIntoFindDialog(tester, pattern);

      await editor.pressKey(
        key: LogicalKeyboardKey.enter,
      );

      //checking if current selection consists an occurance of matched pattern.
      //we expect the last occurance of the pattern to be found, thus that should
      //be the current selection.
      checkCurrentSelection(editor, [1], 0, pattern.length);

      //now pressing the icon button for previous match should select
      //node at path [0].
      await tester.tap(find.byKey(previousBtnKey));
      await tester.pumpAndSettle();

      checkCurrentSelection(editor, [0], 0, pattern.length);

      //now pressing the icon button for previous match should select
      //node at path [1], since there is no node before node at [0].
      await tester.tap(find.byKey(previousBtnKey));
      await tester.pumpAndSettle();

      checkCurrentSelection(editor, [1], 0, pattern.length);

      //now pressing the icon button for next match should select
      //node at path[0], since there is no node after node at [1].
      await tester.tap(find.byKey(nextBtnKey));
      await tester.pumpAndSettle();

      checkCurrentSelection(editor, [0], 0, pattern.length);

      //now pressing the icon button for next match should select
      //node at path [1].
      await tester.tap(find.byKey(nextBtnKey));
      await tester.pumpAndSettle();

      checkCurrentSelection(editor, [1], 0, pattern.length);

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

      await pressFindAndReplaceCommand(editor);

      await tester.pumpAndSettle();

      expect(find.byType(FindMenuWidget), findsOneWidget);

      await enterInputIntoFindDialog(tester, pattern);

      await editor.pressKey(
        key: LogicalKeyboardKey.enter,
      );

      final selection =
          editor.editorState.service.selectionService.currentSelection.value;
      expect(selection, isNotNull);

      final node = editor.nodeAtPath([2]);
      expect(node, isNotNull);

      //node is highlighted while menu is active
      checkIfNotHighlighted(node!, selection!, expectedResult: false);

      //presses the close button
      await tester.tap(find.byKey(closeBtnKey));
      await tester.pumpAndSettle();

      //closes the findMenuWidget
      expect(find.byType(FindMenuWidget), findsNothing);

      //we expect that the current selected node is NOT highlighted.
      checkIfNotHighlighted(node, selection, expectedResult: true);

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

      await pressFindAndReplaceCommand(editor);

      await tester.pumpAndSettle();

      await enterInputIntoFindDialog(tester, pattern);

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
      checkIfNotHighlighted(node!, selectionAtNode1, expectedResult: true);

      //now we will change the pattern to Flutter and search it
      pattern = 'Flutter';
      await enterInputIntoFindDialog(tester, pattern);

      //finds the pattern Flutter
      await editor.pressKey(
        key: LogicalKeyboardKey.enter,
      );

      //we expect that the current selected node is highlighted.
      checkIfNotHighlighted(node, selectionAtNode1, expectedResult: false);

      final selectionAtNode0 = Selection.single(
        path: [0],
        startOffset: 0,
        endOffset: textLine1.length,
      );
      node = editor.nodeAtPath([0]);
      expect(node, isNotNull);

      //we expect that the current node at path 0 to be NOT highlighted.
      checkIfNotHighlighted(node!, selectionAtNode0, expectedResult: true);

      await editor.dispose();
    });
  });
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

  await pressFindAndReplaceCommand(editor);

  await tester.pumpAndSettle();

  expect(find.byType(FindMenuWidget), findsOneWidget);

  await enterInputIntoFindDialog(tester, pattern);
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

  checkIfNotHighlighted(node!, selection, expectedResult: expectedResult);

  await editor.dispose();
}
