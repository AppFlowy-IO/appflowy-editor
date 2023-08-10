import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/find_replace_menu/find_replace_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../infra/testable_editor.dart';

const text = 'Welcome to Appflowy 😁';
const Color kSelectedHighlightColor = Colors.yellow;
const Color kUnselectedHighlightColor = Colors.lightGreen;
String kSelectedHCHex = kSelectedHighlightColor.toHex();
String kUnselectedHCHex = kUnselectedHighlightColor.toHex();

class TestableFindAndReplaceCommands {
  TestableFindAndReplaceCommands({
    required this.context,
    this.selectedHighlightColor = kSelectedHighlightColor,
    this.unselectedHighlightColor = kUnselectedHighlightColor,
  });

  final Color selectedHighlightColor;
  final Color unselectedHighlightColor;
  final BuildContext context;

  List<CommandShortcutEvent> get testableFindAndReplaceCommands =>
      findAndReplaceCommands(
        context: context,
        localizations: FindReplaceLocalizations(
          find: 'Find',
          previousMatch: 'Previous match',
          nextMatch: 'Next match',
          close: 'Close',
          replace: 'Replace',
          replaceAll: 'Replace all',
        ),
        style: FindReplaceStyle(
          selectedHighlightColor: selectedHighlightColor,
          unselectedHighlightColor: unselectedHighlightColor,
        ),
      );
}

Future<void> prepareFindAndReplaceDialog(
  WidgetTester tester, {
  bool openReplace = false,
}) async {
  final editor = tester.editor;
  editor.addParagraphs(3, initialText: text);

  await editor.startTesting();
  await editor.updateSelection(Selection.single(path: [0], startOffset: 0));

  await pressFindAndReplaceCommand(editor, openReplace: openReplace);

  await tester.pumpAndSettle(const Duration(milliseconds: 1000));

  expect(find.byType(FindMenuWidget), findsOneWidget);
}

Future<void> enterInputIntoFindDialog(
  WidgetTester tester,
  String pattern, {
  bool isReplaceField = false,
}) async {
  final textInputKey = isReplaceField
      ? const Key('replaceTextField')
      : const Key('findTextField');
  await tester.tap(find.byKey(textInputKey));
  await tester.enterText(find.byKey(textInputKey), pattern);
  await tester.pumpAndSettle();
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pumpAndSettle();
}

Future<void> pressFindAndReplaceCommand(
  TestableEditor editor, {
  bool openReplace = false,
}) async {
  await editor.pressKey(
    key: openReplace ? LogicalKeyboardKey.keyH : LogicalKeyboardKey.keyF,
    isMetaPressed: Platform.isMacOS,
    isControlPressed: !Platform.isMacOS,
  );
}

void checkIfNotHighlighted(
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
            (e) =>
                e.attributes?[AppFlowyRichTextKeys.findBackgroundColor] == null,
          );
    }),
    expectedResult,
  );
}

void checkIfHighlightedWithProperColors(
  Node node,
  Selection selection,
  String expectedColor,
) {
  expect(
    node.allSatisfyInSelection(selection, (delta) {
      return delta.whereType<TextInsert>().every(
            (e) =>
                e.attributes?[AppFlowyRichTextKeys.findBackgroundColor] ==
                expectedColor,
          );
    }),
    true,
  );
}

void checkCurrentSelection(
  TestableEditor editor,
  Path path,
  int startOffset,
  int endOffset,
) {
  final selection =
      editor.editorState.service.selectionService.currentSelection.value;

  expect(selection != null, true);
  expect(selection!.start, Position(path: path, offset: startOffset));
  expect(selection.end, Position(path: path, offset: endOffset));
}

Selection getSelectionAtPath(Path path, int startOffset, int endOffset) {
  return Selection(
    start: Position(path: path, offset: startOffset),
    end: Position(path: path, offset: endOffset),
  );
}
