import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/find_replace_menu/find_replace_widget.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../infra/testable_editor.dart';
import 'find_replace_menu_utils.dart';

// Reproduction for https://github.com/AppFlowy-IO/AppFlowy/issues/8802
// "[Bug] can not search with Ctrl-F" - the find/replace overlay disappears
// as soon as the user starts typing a search term.
void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('find_replace_menu.dart findMenu stays open while typing', () {
    testWidgets('menu remains mounted after typing each character',
        (tester) async {
      final editor = tester.editor;
      editor.addParagraphs(3, initialText: text);

      await editor.startTesting();
      await editor.updateSelection(Selection.single(path: [0], startOffset: 0));

      await pressFindAndReplaceCommand(editor);
      await tester.pumpAndSettle();

      expect(find.byType(FindAndReplaceMenuWidget), findsOneWidget);

      // Type into the find field one character at a time, the way a real
      // user would, and check the overlay survives every keystroke.
      const pattern = 'Welcome';
      final findField = find.byKey(const Key('findTextField'));
      String typed = '';
      for (final char in pattern.split('')) {
        typed += char;
        await tester.enterText(findField, typed);
        await tester.pump();

        expect(
          find.byType(FindAndReplaceMenuWidget),
          findsOneWidget,
          reason:
              'find menu disappeared after typing "$typed" (pattern so far)',
        );
      }

      await tester.pumpAndSettle();
      expect(find.byType(FindAndReplaceMenuWidget), findsOneWidget);

      await editor.dispose();
    });

    testWidgets(
        'menu remains mounted after typing a character with no matches',
        (tester) async {
      final editor = tester.editor;
      editor.addParagraphs(3, initialText: text);

      await editor.startTesting();
      await editor.updateSelection(Selection.single(path: [0], startOffset: 0));

      await pressFindAndReplaceCommand(editor);
      await tester.pumpAndSettle();

      expect(find.byType(FindAndReplaceMenuWidget), findsOneWidget);

      // 'z' does not appear anywhere in `text`, so this exercises the
      // zero-match branch of SearchServiceV3._findAndHighlight.
      final findField = find.byKey(const Key('findTextField'));
      await tester.enterText(findField, 'z');
      await tester.pump();

      expect(
        find.byType(FindAndReplaceMenuWidget),
        findsOneWidget,
        reason: 'find menu disappeared after typing a non-matching character',
      );

      await editor.dispose();
    });
  });
}
