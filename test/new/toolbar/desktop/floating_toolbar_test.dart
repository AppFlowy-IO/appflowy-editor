import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../infra/testable_editor.dart';

void main() async {
  final List<String> expectedToolbarItemsOrder = [
    'editor.paragraph',
    'editor.h1',
    'editor.h2',
    'editor.h3',
    'editor.placeholder',
    'editor.underline',
    'editor.bold',
    'editor.italic',
    'editor.strikethrough',
    'editor.code',
    'editor.placeholder',
    'editor.quote',
    'editor.bulleted_list',
    'editor.numbered_list',
    'editor.placeholder',
    'editor.link',
    'editor.textColor',
    'editor.highlightColor',
  ];
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
      await tester.pumpAndSettle();

      final floatingToolbar = find.byType(FloatingToolbarWidget);
      expect(floatingToolbar, findsOneWidget);
      expect(tester.getTopLeft(floatingToolbar).dy >= 0, true);
      await editor.dispose();
    });

    testWidgets(
        'select the first line of the document, the toolbar layout should be right to left',
        (tester) async {
      final editor = tester.editor..addParagraphs(3, initialText: text);
      await editor.startTesting(
        withFloatingToolbar: true,
        toolbarLayoutDirection: TextDirection.rtl,
      );
      final selection = Selection.single(
        path: [0],
        startOffset: 0,
        endOffset: text.length,
      );
      await editor.updateSelection(selection);
      await tester.pumpAndSettle();

      final floatingToolbar = find.byType(FloatingToolbarWidget);
      expect(floatingToolbar, findsOneWidget);

      final List<ToolbarItem> toolbarActiveItems =
          tester.widget<FloatingToolbarWidget>(floatingToolbar).activeItems;
      expect(toolbarActiveItems.length, expectedToolbarItemsOrder.length);

      for (int index = 0; index < toolbarActiveItems.length; index++) {
        expect(
          toolbarActiveItems[index].id,
          expectedToolbarItemsOrder[toolbarActiveItems.length - index - 1],
        );
      }
      expect(tester.getTopLeft(floatingToolbar).dy >= 0, true);
      await editor.dispose();
    });

    testWidgets(
        'select the first line of the document, the toolbar layout should be left to right',
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
      await tester.pumpAndSettle();

      final floatingToolbar = find.byType(FloatingToolbarWidget);
      expect(floatingToolbar, findsOneWidget);

      final List<ToolbarItem> toolbarActiveItems =
          tester.widget<FloatingToolbarWidget>(floatingToolbar).activeItems;
      expect(toolbarActiveItems.length, expectedToolbarItemsOrder.length);

      for (int index = 0; index < toolbarActiveItems.length; index++) {
        expect(toolbarActiveItems[index].id, expectedToolbarItemsOrder[index]);
      }
      expect(tester.getTopLeft(floatingToolbar).dy >= 0, true);
      await editor.dispose();
    });
  });
}
