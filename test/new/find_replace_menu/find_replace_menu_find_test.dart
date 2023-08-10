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

      // The prepareFindDialog method only checks if FindMenuWidget is present
      // so here we also check if FindMenuWidget contains TextField
      // and IconButtons or not.
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(IconButton), findsAtLeastNWidgets(4));

      await tester.editor.dispose();
    });

    testWidgets('disappears when close is called', (tester) async {
      await prepareFindAndReplaceDialog(tester);

      // Check if find menu disappears if the close button is tapped.
      await tester.tap(find.byKey(const Key('closeButton')));
      await tester.pumpAndSettle();

      expect(find.byType(FindMenuWidget), findsNothing);
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(IconButton), findsNothing);

      await tester.editor.dispose();
    });

    testWidgets('does not highlight anything when empty string searched',
        (tester) async {
      // We expect nothing to be highlighted
      await _prepareFindAndInputPattern(tester, '', true);
    });

    testWidgets('works properly when match is not found', (tester) async {
      // We expect nothing to be highlighted
      await _prepareFindAndInputPattern(tester, 'Flutter', true);
    });

    testWidgets('highlights properly when match is found', (tester) async {
      // We expect something to be highlighted
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

      // Checking if current selection consists an occurance of matched pattern.
      final selection =
          editor.editorState.service.selectionService.currentSelection.value;

      // We expect the first occurance of the pattern to be found and selected,
      // this is because we send a testTextInput.receiveAction(TextInputAction.done)
      // event during submitting our text input, thus the second match is selected.
      expect(selection != null, true);
      expect(selection!.start, Position(path: [0], offset: 0));
      expect(selection.end, Position(path: [0], offset: pattern.length));

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

      // This will call naviateToMatch and select the first match
      await editor.pressKey(
        key: LogicalKeyboardKey.enter,
      );

      // Checking if current selection consists an occurance of matched pattern.
      // we expect the first occurance of the pattern to be found and selected
      checkCurrentSelection(editor, [0], 0, pattern.length);

      // Now pressing the icon button for previous match should select
      // node at path [1].
      await tester.tap(find.byKey(previousBtnKey));
      await tester.pumpAndSettle();

      checkCurrentSelection(editor, [1], 0, pattern.length);

      await tester.tap(find.byKey(previousBtnKey));
      await tester.pumpAndSettle();

      checkCurrentSelection(editor, [0], 0, pattern.length);

      await tester.tap(find.byKey(nextBtnKey));
      await tester.pumpAndSettle();

      checkCurrentSelection(editor, [1], 0, pattern.length);

      await tester.tap(find.byKey(nextBtnKey));
      await tester.pumpAndSettle();

      checkCurrentSelection(editor, [0], 0, pattern.length);

      await editor.dispose();
    });

    testWidgets('''navigating - selected match is highlighted uniquely
     than unselected matches''', (tester) async {
      const pattern = 'Welcome';
      const previousBtnKey = Key('previousMatchButton');

      final editor = tester.editor;
      editor.addParagraphs(3, initialText: text);

      await editor.startTesting();

      final node0 = editor.nodeAtPath([0]);
      final selection0 = getSelectionAtPath([0], 0, pattern.length);
      final node1 = editor.nodeAtPath([1]);
      final selection1 = getSelectionAtPath([1], 0, pattern.length);
      final node2 = editor.nodeAtPath([2]);
      final selection2 = getSelectionAtPath([2], 0, pattern.length);

      await editor.updateSelection(Selection.single(path: [0], startOffset: 0));

      await pressFindAndReplaceCommand(editor);

      await tester.pumpAndSettle();

      await enterInputIntoFindDialog(tester, pattern);

      // This will call naviateToMatch and select the first match
      await editor.pressKey(
        key: LogicalKeyboardKey.enter,
      );

      // We expect the first occurance of the pattern to be found and selected
      checkCurrentSelection(editor, [0], 0, pattern.length);

      // Check if the current selected match is highlighted properly
      checkIfHighlightedWithProperColors(node0!, selection1, kSelectedHCHex);

      // Unselected matches are highlighted with different color
      checkIfHighlightedWithProperColors(node1!, selection2, kUnselectedHCHex);
      checkIfHighlightedWithProperColors(node2!, selection0, kUnselectedHCHex);

      // Press the icon button for previous match should select node at path [2] (last match)
      await tester.tap(find.byKey(previousBtnKey));

      checkCurrentSelection(editor, [2], 0, pattern.length);
      checkIfHighlightedWithProperColors(node2, selection0, kSelectedHCHex);
      checkIfHighlightedWithProperColors(node0, selection1, kUnselectedHCHex);
      checkIfHighlightedWithProperColors(node1, selection2, kUnselectedHCHex);

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

      // Node is highlighted while menu is active
      checkIfNotHighlighted(node!, selection!, expectedResult: false);

      // Presses the close button
      await tester.tap(find.byKey(closeBtnKey));
      await tester.pumpAndSettle();

      // Closes the findMenuWidget
      expect(find.byType(FindMenuWidget), findsNothing);

      // We expect that the current selected node is NOT highlighted.
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

      expect(find.byType(FindMenuWidget), findsOneWidget);

      await enterInputIntoFindDialog(tester, pattern);

      // Since node at path [1] does not contain match, we expect it to not be highlighted.
      final selectionAtNode1 = Selection.single(
        path: [1],
        startOffset: 0,
        endOffset: textLine2.length,
      );

      Node? node = editor.nodeAtPath([1]);
      expect(node, isNotNull);

      // We expect that the current node at path 1 to be NOT highlighted.
      checkIfNotHighlighted(node!, selectionAtNode1, expectedResult: true);

      // Change the pattern to Flutter and search
      pattern = 'Flutter';
      await enterInputIntoFindDialog(tester, pattern);

      // We expect that the current selected node is highlighted.
      checkIfNotHighlighted(node, selectionAtNode1, expectedResult: false);

      final selectionAtNode0 = Selection.single(
        path: [0],
        startOffset: 0,
        endOffset: textLine1.length,
      );
      node = editor.nodeAtPath([0]);
      expect(node, isNotNull);

      // We expect that the current node at path 0 to be NOT highlighted.
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

  // Pressing enter should trigger the findAndHighlight method, which
  // will find the pattern inside the editor.
  await editor.pressKey(
    key: LogicalKeyboardKey.enter,
  );

  // Since the method will not select anything as searched pattern is
  // empty, the current selection should be equal to previous selection.
  final selection =
      Selection.single(path: [0], startOffset: 0, endOffset: text.length);

  final node = editor.nodeAtPath([0]);
  expect(node, isNotNull);

  checkIfNotHighlighted(node!, selection, expectedResult: expectedResult);

  await editor.dispose();
}
