import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import '../../../../new/infra/testable_editor.dart';
import '../test_helpers/mobile_app_with_toolbar_widget.dart';

void main() {
  group('dividerMobileToolbarItem', () {
    testWidgets(
        'If the user tries to insert a divider while some text is selected, no action should be taken',
        (WidgetTester tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor..addParagraphs(3, initialText: text);
      await editor.startTesting();

      var selection = Selection.single(
        path: [1],
        startOffset: 2,
        endOffset: text.length - 2,
      );

      await editor.updateSelection(selection);
      await tester.pumpWidget(
        Material(
          child: MobileAppWithToolbarWidget(
            editorState: editor.editorState,
            toolbarItems: [
              dividerMobileToolbarItem,
            ],
          ),
        ),
      );

      // Tap divider toolbar item
      final dividerBtn = find.byType(IconButton).first;
      await tester.tap(dividerBtn);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      // Check if the text becomes quote node
      final node = editor.editorState.getNodeAtPath([1]);
      expect(
        node?.type == ParagraphBlockKeys.type,
        true,
      );
    });
    testWidgets(
        'Insert a divider if nothing is selected(selection is collapsed)',
        (WidgetTester tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor..addParagraphs(3, initialText: text);
      await editor.startTesting();

      const originalPath = 1;

      var selection =
          Selection.collapsed(Position(path: [originalPath], offset: 2));

      await editor.updateSelection(selection);
      await tester.pumpWidget(
        Material(
          child: MobileAppWithToolbarWidget(
            editorState: editor.editorState,
            toolbarItems: [
              dividerMobileToolbarItem,
            ],
          ),
        ),
      );

      // Tap divider toolbar item
      final dividerBtn = find.byType(IconButton).first;
      await tester.tap(dividerBtn);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      // Check if the node in the next path become a divider node
      final node = editor.editorState.getNodeAtPath([originalPath + 1]);
      expect(
        node?.type == DividerBlockKeys.type,
        true,
      );
    });
  });
}
