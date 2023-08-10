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

  group('find_replace_menu.dart replaceMenu', () {
    testWidgets('replace menu appears properly', (tester) async {
      await prepareFindAndReplaceDialog(tester, openReplace: true);

      // The prepare method only checks if FindMenuWidget is present
      // so here we also check if FindMenuWidget contains TextField
      // and IconButtons or not.
      // and whether there are two textfields for replace menu as well.
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(IconButton), findsAtLeastNWidgets(6));
    });

    testWidgets('replace menu disappears when close is called', (tester) async {
      await prepareFindAndReplaceDialog(tester, openReplace: true);

      await tester.tap(find.byKey(const Key('closeButton')));
      await tester.pumpAndSettle();

      expect(find.byType(FindMenuWidget), findsNothing);
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(IconButton), findsNothing);
    });

    testWidgets('replace menu does not work when find is not called',
        (tester) async {
      const pattern = 'Flutter';
      final editor = tester.editor;
      editor.addParagraphs(1, initialText: text);

      await editor.startTesting();
      await editor.updateSelection(Selection.single(path: [0], startOffset: 0));

      await pressFindAndReplaceCommand(editor, openReplace: true);

      await tester.pumpAndSettle();

      expect(find.byType(FindMenuWidget), findsOneWidget);

      await enterInputIntoFindDialog(tester, pattern, isReplaceField: true);

      await editor.pressKey(
        key: LogicalKeyboardKey.enter,
      );

      //if nothing is replaced then the original text will remain as it is
      final node = editor.nodeAtPath([0]);
      expect(node!.delta!.toPlainText(), text);

      await editor.dispose();
    });

    testWidgets('replace does not change text when no match is found',
        (tester) async {
      const pattern = 'Flutter';

      final editor = tester.editor;
      editor.addParagraphs(1, initialText: text);

      await editor.startTesting();
      await editor.updateSelection(Selection.single(path: [0], startOffset: 0));

      await pressFindAndReplaceCommand(editor, openReplace: true);

      await tester.pumpAndSettle();
      expect(find.byType(FindMenuWidget), findsOneWidget);

      //we put the pattern in the find dialog and press enter
      await enterInputIntoFindDialog(tester, pattern);
      await editor.pressKey(
        key: LogicalKeyboardKey.enter,
      );
      await tester.pumpAndSettle();

      //now we input some text into the replace text field and try to replace
      await enterInputIntoFindDialog(tester, pattern, isReplaceField: true);
      await editor.pressKey(
        key: LogicalKeyboardKey.enter,
      );
      await tester.pumpAndSettle();

      final node = editor.nodeAtPath([0]);
      expect(node!.delta!.toPlainText(), text);
      await editor.dispose();
    });

    //Before:
    //Welcome to Appflowy 😁
    //After:
    //Salute to Appflowy 😁
    testWidgets('found selected match is replaced properly', (tester) async {
      const patternToBeFound = 'Welcome';
      const replacePattern = 'Salute';
      final expectedText = '$replacePattern${text.substring(7)}';

      final editor = tester.editor;
      editor.addParagraphs(1, initialText: text);

      await editor.startTesting();
      await editor.updateSelection(Selection.single(path: [0], startOffset: 0));

      await pressFindAndReplaceCommand(editor, openReplace: true);

      await tester.pumpAndSettle();
      expect(find.byType(FindMenuWidget), findsOneWidget);

      //we put the pattern in the find dialog and press enter
      await enterInputIntoFindDialog(tester, patternToBeFound);
      await editor.pressKey(
        key: LogicalKeyboardKey.enter,
      );
      await tester.pumpAndSettle();

      //we expect the found pattern to be highlighted
      final node = editor.nodeAtPath([0]);
      final selection =
          Selection.single(path: [0], startOffset: 0, endOffset: text.length);

      checkIfNotHighlighted(node!, selection, expectedResult: false);

      //now we input some text into the replace text field and try to replace
      await enterInputIntoFindDialog(
        tester,
        replacePattern,
        isReplaceField: true,
      );
      await editor.pressKey(
        key: LogicalKeyboardKey.enter,
      );
      await tester.pumpAndSettle();

      expect(node.delta!.toPlainText(), expectedText);

      await editor.dispose();
    });

    testWidgets('''within multiple matched patterns replace 
      should only replace the currently selected match''', (tester) async {
      const patternToBeFound = 'Welcome';
      const replacePattern = 'Salute';
      final expectedText = '$replacePattern${text.substring(7)}';

      final editor = tester.editor;
      editor.addParagraphs(3, initialText: text);

      await editor.startTesting();
      await editor.updateSelection(Selection.single(path: [0], startOffset: 0));

      await pressFindAndReplaceCommand(editor, openReplace: true);

      await tester.pumpAndSettle();
      expect(find.byType(FindMenuWidget), findsOneWidget);

      // we put the pattern in the find dialog and press enter
      await enterInputIntoFindDialog(tester, patternToBeFound);
      await editor.pressKey(key: LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      // lets check after find operation, the first match is selected.
      checkCurrentSelection(editor, [0], 0, patternToBeFound.length);

      // now we input some text into the replace text field and try to replace
      await enterInputIntoFindDialog(
        tester,
        replacePattern,
        isReplaceField: true,
      );
      await editor.pressKey(
        key: LogicalKeyboardKey.enter,
      );
      await tester.pumpAndSettle();

      //only the node at path 0 should get replaced, all other nodes should stay as before.
      final lastNode = editor.nodeAtPath([0]);
      expect(lastNode!.delta!.toPlainText(), expectedText);

      final middleNode = editor.nodeAtPath([1]);
      expect(middleNode!.delta!.toPlainText(), text);

      final firstNode = editor.nodeAtPath([2]);
      expect(firstNode!.delta!.toPlainText(), text);

      await editor.dispose();
    });

    testWidgets('replace all on found matches', (tester) async {
      const patternToBeFound = 'Welcome';
      const replacePattern = 'Salute';
      final expectedText = '$replacePattern${text.substring(7)}';
      const replaceAllBtn = Key('replaceAllButton');
      const lines = 3;

      final editor = tester.editor;
      editor.addParagraphs(lines, initialText: text);

      await editor.startTesting();
      await editor.updateSelection(Selection.single(path: [0], startOffset: 0));

      await pressFindAndReplaceCommand(editor, openReplace: true);

      await tester.pumpAndSettle();
      expect(find.byType(FindMenuWidget), findsOneWidget);

      //we put the pattern in the find dialog and press enter
      await enterInputIntoFindDialog(tester, patternToBeFound);
      await editor.pressKey(
        key: LogicalKeyboardKey.enter,
      );
      await tester.pumpAndSettle();

      //now we input some text into the replace text field and try replace all
      await enterInputIntoFindDialog(
        tester,
        replacePattern,
        isReplaceField: true,
      );

      await tester.tap(find.byKey(replaceAllBtn));
      await tester.pumpAndSettle();

      //all matches should be replaced
      for (var i = 0; i < lines; i++) {
        final node = editor.nodeAtPath([i]);
        expect(node!.delta!.toPlainText(), expectedText);
      }
      await editor.dispose();
    });
  });
}
