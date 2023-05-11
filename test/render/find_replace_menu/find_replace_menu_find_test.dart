import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appflowy_editor/src/render/find_replace_menu/find_replace_widget.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import '../../infra/test_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('find_replace_menu.dart findMenu', () {
    testWidgets('find menu appears properly', (tester) async {
      await _prepare(tester, lines: 3);

      //the prepare method only checks if FindMenuWidget is present
      //so here we also check if FindMenuWidget contains TextField
      //and IconButtons or not.
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(IconButton), findsAtLeastNWidgets(4));
    });

    testWidgets('find menu disappears when close is called', (tester) async {
      await _prepare(tester, lines: 3);

      //lets check if find menu disappears if the close button is tapped.
      await tester.tap(find.byKey(const Key('closeButton')));
      await tester.pumpAndSettle();

      expect(find.byType(FindMenuWidget), findsNothing);
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(IconButton), findsNothing);
    });

    testWidgets('find menu does not work with empty input', (tester) async {
      const pattern = '';

      //we are passing empty string for pattern
      final editor = await _prepareWithTextInputForFind(
        tester,
        lines: 1,
        pattern: pattern,
      );

      //since the method will not select anything as searched pattern is
      //empty, the current selection should be equal to previous selection.
      final selection =
          editor.editorState.service.selectionService.currentSelection.value;

      expect(selection, Selection.single(path: [0], startOffset: 0));

      //we can do this because there is only one text node.
      final textNode = editor.nodeAtPath([0]) as TextNode;

      //we expect that nothing is highlighted in our current document.
      expect(
        textNode.allSatisfyInSelection(
          selection!,
          BuiltInAttributeKey.backgroundColor,
          (value) => value == '0x00000000',
        ),
        true,
      );
    });

    testWidgets('find menu works properly when match is not found',
        (tester) async {
      const pattern = 'Flutter';

      final editor = await _prepareWithTextInputForFind(
        tester,
        lines: 1,
        pattern: pattern,
      );

      //fetching the current selection
      final selection =
          editor.editorState.service.selectionService.currentSelection.value;

      //since no match is found the current selection should not be different
      //from initial selection.
      expect(selection != null, true);
      expect(selection, Selection.single(path: [0], startOffset: 0));
    });

    testWidgets('found matches are highlighted', (tester) async {
      const pattern = 'Welcome';

      final editor = await _prepareWithTextInputForFind(
        tester,
        lines: 3,
        pattern: pattern,
      );

      //checking if current selection consists an occurance of matched pattern.
      final selection =
          editor.editorState.service.selectionService.currentSelection.value;

      //we expect the last occurance of the pattern to be found, thus that should
      //be the current selection.
      expect(selection != null, true);
      expect(selection!.start, Position(path: [2], offset: 0));
      expect(selection.end, Position(path: [2], offset: pattern.length));

      //check whether the node with found occurance of patten is highlighted
      final textNode = editor.nodeAtPath([2]) as TextNode;

      //we expect that the current selected node is highlighted.
      //we can confirm that by saying that the node's backgroung color is not white.
      expect(
        textNode.allSatisfyInSelection(
          selection,
          BuiltInAttributeKey.backgroundColor,
          (value) => value != '0x00000000',
        ),
        true,
      );
    });

    testWidgets('navigating to previous matches works', (tester) async {
      const pattern = 'Welcome';
      const previousBtnKey = Key('previousMatchButton');

      final editor = await _prepareWithTextInputForFind(
        tester,
        lines: 2,
        pattern: pattern,
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
    });

    testWidgets('navigating to next matches works', (tester) async {
      const pattern = 'Welcome';
      const nextBtnKey = Key('nextMatchButton');

      final editor = await _prepareWithTextInputForFind(
        tester,
        lines: 3,
        pattern: pattern,
      );

      //the last found occurance should be selected
      var selection =
          editor.editorState.service.selectionService.currentSelection.value;

      expect(selection != null, true);
      expect(selection!.start, Position(path: [2], offset: 0));
      expect(selection.end, Position(path: [2], offset: pattern.length));

      //now pressing the icon button for next match should select
      //node at path [0], since there are no nodes after node at [2].
      await tester.tap(find.byKey(nextBtnKey));
      await tester.pumpAndSettle();

      selection =
          editor.editorState.service.selectionService.currentSelection.value;

      expect(selection != null, true);
      expect(selection!.start, Position(path: [0], offset: 0));
      expect(selection.end, Position(path: [0], offset: pattern.length));

      //now pressing the icon button for previous match should select
      //node at path [1].
      await tester.tap(find.byKey(nextBtnKey));
      await tester.pumpAndSettle();

      selection =
          editor.editorState.service.selectionService.currentSelection.value;

      expect(selection != null, true);
      expect(selection!.start, Position(path: [1], offset: 0));
      expect(selection.end, Position(path: [1], offset: pattern.length));
    });

    testWidgets('found matches are unhighlighted when findMenu closed',
        (tester) async {
      const pattern = 'Welcome';
      const closeBtnKey = Key('closeButton');

      final editor = await _prepareWithTextInputForFind(
        tester,
        lines: 3,
        pattern: pattern,
      );

      final selection =
          editor.editorState.service.selectionService.currentSelection.value;

      final textNode = editor.nodeAtPath([2]) as TextNode;

      //node is highlighted while menu is active
      expect(
        textNode.allSatisfyInSelection(
          selection!,
          BuiltInAttributeKey.backgroundColor,
          (value) => value != '0x00000000',
        ),
        true,
      );

      //presses the close button
      await tester.tap(find.byKey(closeBtnKey));
      await tester.pumpAndSettle();

      //closes the findMenuWidget
      expect(find.byType(FindMenuWidget), findsNothing);

      //node is unhighlighted after the menu is closed
      expect(
        textNode.allSatisfyInSelection(
          selection,
          BuiltInAttributeKey.backgroundColor,
          (value) => value == '0x00000000',
        ),
        true,
      );
    });

    testWidgets('old matches are unhighlighted when new pattern is searched',
        (tester) async {
      const textInputKey = Key('findTextField');

      const textLine1 = 'Welcome to Appflowy 😁';
      const textLine2 = 'Appflowy is made with Flutter, Rust and ❤️';
      var pattern = 'Welcome';

      final editor = tester.editor
        ..insertTextNode(textLine1)
        ..insertTextNode(textLine2);

      await editor.startTesting();
      await editor.updateSelection(Selection.single(path: [0], startOffset: 0));

      if (Platform.isWindows || Platform.isLinux) {
        await editor.pressLogicKey(
          key: LogicalKeyboardKey.keyF,
          isControlPressed: true,
        );
      } else {
        await editor.pressLogicKey(
          key: LogicalKeyboardKey.keyF,
          isMetaPressed: true,
        );
      }

      await tester.pumpAndSettle(const Duration(milliseconds: 1000));

      await tester.tap(find.byKey(textInputKey));
      await tester.enterText(find.byKey(textInputKey), pattern);
      await tester.pumpAndSettle();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      //finds the pattern
      await editor.pressLogicKey(
        key: LogicalKeyboardKey.enter,
      );

      //since node at path [1] does not contain match, we expect it
      //to be not highlighted.
      var selection = Selection.single(path: [1], startOffset: 0);
      var textNode = editor.nodeAtPath([1]) as TextNode;

      expect(
        textNode.allSatisfyInSelection(
          selection,
          BuiltInAttributeKey.backgroundColor,
          (value) => value == '0x00000000',
        ),
        true,
      );

      //now we will change the pattern to Flutter and search it
      pattern = 'Flutter';
      await tester.tap(find.byKey(textInputKey));
      await tester.enterText(find.byKey(textInputKey), pattern);
      await tester.pumpAndSettle();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      //finds the pattern Flutter
      await editor.pressLogicKey(
        key: LogicalKeyboardKey.enter,
      );

      //now we expect the text node at path 1 to contain highlighted pattern
      expect(
        textNode.allSatisfyInSelection(
          selection,
          BuiltInAttributeKey.backgroundColor,
          (value) => value != '0x00000000',
        ),
        true,
      );
    });
  });
}

Future<EditorWidgetTester> _prepare(
  WidgetTester tester, {
  int lines = 1,
}) async {
  const text = 'Welcome to Appflowy 😁';
  final editor = tester.editor;
  for (var i = 0; i < lines; i++) {
    editor.insertTextNode(text);
  }
  await editor.startTesting();
  await editor.updateSelection(Selection.single(path: [0], startOffset: 0));

  if (Platform.isWindows || Platform.isLinux) {
    await editor.pressLogicKey(
      key: LogicalKeyboardKey.keyF,
      isControlPressed: true,
    );
  } else {
    await editor.pressLogicKey(
      key: LogicalKeyboardKey.keyF,
      isMetaPressed: true,
    );
  }

  await tester.pumpAndSettle(const Duration(milliseconds: 1000));

  expect(find.byType(FindMenuWidget), findsOneWidget);

  return Future.value(editor);
}

Future<EditorWidgetTester> _prepareWithTextInputForFind(
  WidgetTester tester, {
  int lines = 1,
  String pattern = "Welcome",
}) async {
  const text = 'Welcome to Appflowy 😁';
  const textInputKey = Key('findTextField');
  final editor = tester.editor;
  for (var i = 0; i < lines; i++) {
    editor.insertTextNode(text);
  }
  await editor.startTesting();
  await editor.updateSelection(Selection.single(path: [0], startOffset: 0));

  if (Platform.isWindows || Platform.isLinux) {
    await editor.pressLogicKey(
      key: LogicalKeyboardKey.keyF,
      isControlPressed: true,
    );
  } else {
    await editor.pressLogicKey(
      key: LogicalKeyboardKey.keyF,
      isMetaPressed: true,
    );
  }

  await tester.pumpAndSettle(const Duration(milliseconds: 1000));

  expect(find.byType(FindMenuWidget), findsOneWidget);

  await tester.tap(find.byKey(textInputKey));
  await tester.enterText(find.byKey(textInputKey), pattern);
  await tester.pumpAndSettle();
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();

  //pressing enter should trigger the findAndHighlight method, which
  //will find the pattern inside the editor.
  await editor.pressLogicKey(
    key: LogicalKeyboardKey.enter,
  );

  return Future.value(editor);
}
