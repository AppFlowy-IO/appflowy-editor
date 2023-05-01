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

  group('find_replace_menu.dart replaceMenu', () {
    testWidgets('replace menu appears properly', (tester) async {
      await _prepare(tester, lines: 3);

      //the prepare method only checks if FindMenuWidget is present
      //so here we also check if FindMenuWidget contains TextField
      //and IconButtons or not.
      //and whether there are two textfields for replace menu as well.
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(IconButton), findsAtLeastNWidgets(6));
    });

    testWidgets('replace menu disappears when close is called', (tester) async {
      await _prepare(tester, lines: 3);

      await tester.tap(find.byKey(const Key('closeButton')));
      await tester.pumpAndSettle();

      expect(find.byType(FindMenuWidget), findsNothing);
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(IconButton), findsNothing);
    });

    testWidgets('replace menu does not work when find is not called',
        (tester) async {
      const textInputKey = Key('replaceTextField');
      const pattern = 'Flutter';
      final editor = await _prepare(tester);

      await tester.tap(find.byKey(textInputKey));
      await tester.enterText(find.byKey(textInputKey), pattern);
      await tester.pumpAndSettle();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      //pressing enter should trigger the replaceSelected method
      await editor.pressLogicKey(
        key: LogicalKeyboardKey.enter,
      );
      await tester.pumpAndSettle();

      //note our document only has one node
      final textNode = editor.nodeAtPath([0]) as TextNode;
      const expectedText = 'Welcome to Appflowy 😁';
      expect(textNode.toPlainText(), expectedText);
    });

    testWidgets('replace does not change text when no match is found',
        (tester) async {
      const textInputKey = Key('replaceTextField');
      const pattern = 'Flutter';

      final editor = await _prepareWithTextInputForFind(
        tester,
        lines: 1,
        pattern: pattern,
      );

      await tester.tap(find.byKey(textInputKey));
      await tester.enterText(find.byKey(textInputKey), pattern);
      await tester.pumpAndSettle();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      await editor.pressLogicKey(
        key: LogicalKeyboardKey.enter,
      );
      await tester.pumpAndSettle();

      final textNode = editor.nodeAtPath([0]) as TextNode;
      const expectedText = 'Welcome to Appflowy 😁';
      expect(textNode.toPlainText(), expectedText);
    });

    testWidgets('found selected match is replaced properly', (tester) async {
      const patternToBeFound = 'Welcome';
      const replacePattern = 'Salute';
      const textInputKey = Key('replaceTextField');

      final editor = await _prepareWithTextInputForFind(
        tester,
        lines: 3,
        pattern: patternToBeFound,
      );

      //check if matches are not yet replaced
      var textNode = editor.nodeAtPath([2]) as TextNode;
      var expectedText = '$patternToBeFound to Appflowy 😁';
      expect(textNode.toPlainText(), expectedText);

      //we select the replace text field and provide replacePattern
      await tester.tap(find.byKey(textInputKey));
      await tester.enterText(find.byKey(textInputKey), replacePattern);
      await tester.pumpAndSettle();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      await editor.pressLogicKey(
        key: LogicalKeyboardKey.enter,
      );

      await tester.pumpAndSettle();

      //we know that the findAndHighlight method selects the last
      //matched occurance in the editor document.
      textNode = editor.nodeAtPath([2]) as TextNode;
      expectedText = '$replacePattern to Appflowy 😁';
      expect(textNode.toPlainText(), expectedText);

      //also check if other matches are not yet replaced
      textNode = editor.nodeAtPath([1]) as TextNode;
      expectedText = '$patternToBeFound to Appflowy 😁';
      expect(textNode.toPlainText(), expectedText);
    });

    testWidgets('replace all on found matches', (tester) async {
      const patternToBeFound = 'Welcome';
      const replacePattern = 'Salute';
      const expectedText = '$replacePattern to Appflowy 😁';
      const lines = 3;

      const textInputKey = Key('replaceTextField');
      const replaceAllBtn = Key('replaceAllButton');

      final editor = await _prepareWithTextInputForFind(
        tester,
        lines: lines,
        pattern: patternToBeFound,
      );

      //check if matches are not yet replaced
      var textNode = editor.nodeAtPath([2]) as TextNode;
      var originalText = '$patternToBeFound to Appflowy 😁';
      expect(textNode.toPlainText(), originalText);

      await tester.tap(find.byKey(textInputKey));
      await tester.enterText(find.byKey(textInputKey), replacePattern);
      await tester.pumpAndSettle();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(replaceAllBtn));
      await tester.pumpAndSettle();

      //all matches should be replaced
      for (var i = 0; i < lines; i++) {
        textNode = editor.nodeAtPath([i]) as TextNode;
        expect(textNode.toPlainText(), expectedText);
      }
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
      key: LogicalKeyboardKey.keyH,
      isControlPressed: true,
    );
  } else {
    await editor.pressLogicKey(
      key: LogicalKeyboardKey.keyH,
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
      key: LogicalKeyboardKey.keyH,
      isControlPressed: true,
    );
  } else {
    await editor.pressLogicKey(
      key: LogicalKeyboardKey.keyH,
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
