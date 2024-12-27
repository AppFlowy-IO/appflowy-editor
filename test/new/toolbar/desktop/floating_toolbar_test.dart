import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../infra/testable_editor.dart';

void main() async {
  group('floating toolbar', () {
    const text = 'Welcome to AppFlowy Editor 🔥!';

    testWidgets(
        'select the first line of the document, the toolbar should not be blocked',
        (tester) async {
      final editor = tester.editor..addParagraphs(3, initialText: text);
      await editor.startTesting(
        withFloatingToolbar: true,
      );

      final selection = Selection.single(
        path: [0],
        startOffset: 0,
        endOffset: text.length,
      );
      await editor.updateSelection(selection);

      final floatingToolbar = find.byType(FloatingToolbarWidget);
      expect(floatingToolbar, findsOneWidget);
      expect(tester.getTopLeft(floatingToolbar).dy >= 0, true);

      await editor.dispose();
    });

    testWidgets(
        'select the first line of the document, the toolbar layout should be right to left in RTL mode',
        (tester) async {
      final editor = tester.editor..addParagraphs(3, initialText: text);
      await editor.startTesting(
        withFloatingToolbar: true,
        textDirection: TextDirection.rtl,
      );

      final selection = Selection.single(
        path: [0],
        startOffset: 0,
        endOffset: text.length,
      );
      await editor.updateSelection(selection);

      final floatingToolbar = find.byType(FloatingToolbarWidget);
      expect(floatingToolbar, findsOneWidget);
      final floatingToolbarContainer = tester.widget<Row>(
        find.byKey(floatingToolbarContainerKey),
      );
      expect(floatingToolbarContainer.textDirection, TextDirection.rtl);
      final List<Widget> toolbarItemWidgets = floatingToolbarContainer.children;
      expect(
        toolbarItemWidgets.length,
        // the floating toolbar items will add the divider between the groups,
        //  so the length of the toolbar items will be the sum of the (floatingToolbarItems.length +
        //  the number of the groups) - 1.
        floatingToolbarItems.length +
            floatingToolbarItems.map((e) => e.group).toSet().length -
            1,
      );

      final expectedIds = floatingToolbarItems.map((e) => e.id).toList();
      var j = 0;
      for (int i = 0; i < toolbarItemWidgets.length; i++) {
        final id = '${floatingToolbarItemPrefixKey}_${expectedIds[j]}_$i';
        final key = toolbarItemWidgets[i].key as ValueKey;
        if (key.value.contains(placeholderItem.id)) {
          continue;
        }
        expect(key, Key(id));
        j++;
      }

      await editor.dispose();
    });

    testWidgets('select multiple line should show bullet and number list item',
        (tester) async {
      final editor = tester.editor..addParagraphs(3, initialText: text);
      await editor.startTesting(withFloatingToolbar: true);

      final selection = Selection(
        start: Position(path: [0], offset: 7),
        end: Position(path: [2], offset: 3),
      );
      await editor.updateSelection(selection);

      final floatingToolbar = find.byType(FloatingToolbarWidget);
      final bulletListItem = find.byWidgetPredicate(
        (w) => w is SVGIconItemWidget && w.iconName == 'toolbar/bulleted_list',
      );
      final numberListItem = find.byWidgetPredicate(
        (w) => w is SVGIconItemWidget && w.iconName == 'toolbar/numbered_list',
      );
      expect(floatingToolbar, findsOneWidget);
      expect(bulletListItem, findsOneWidget);
      expect(numberListItem, findsOneWidget);

      await editor.dispose();
    });

    testWidgets('select invisible content should not show the toolbar',
        (tester) async {
      final editor = tester.editor..addParagraphs(3, initialText: '');
      await editor.startTesting(withFloatingToolbar: true);

      final selection = Selection(
        start: Position(path: [0], offset: 0),
        end: Position(path: [2], offset: 0),
      );
      await editor.updateSelection(selection);

      expect(find.byType(FloatingToolbarWidget), findsNothing);

      await editor.dispose();
    });
  });
}
