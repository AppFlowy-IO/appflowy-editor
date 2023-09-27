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
  });
}
