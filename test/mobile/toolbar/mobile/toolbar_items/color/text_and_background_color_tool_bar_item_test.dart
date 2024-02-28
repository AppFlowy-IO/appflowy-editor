import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../new/infra/testable_editor.dart';
import '../../test_helpers/mobile_app_with_toolbar_widget.dart';

void main() {
  testWidgets('textAndBackgroundColorMobileToolbarItem',
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
            buildTextAndBackgroundColorMobileToolbarItem(),
          ],
        ),
      ),
    );

    // Tap color toolbar item
    await tester.tap(find.byType(IconButton).first);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // Show its menu and it has a tabbar to switch between text and background color
    expect(find.byType(MobileToolbarItemMenu), findsOneWidget);
    expect(
      find.text(AppFlowyEditorL10n.current.textColor),
      findsOneWidget,
    );
    expect(
      find.text(AppFlowyEditorL10n.current.backgroundColor),
      findsOneWidget,
    );

    // Test text color tab
    // It has 9 buttons(default setting is clear + 8 colors)
    expect(find.byType(ClearColorButton), findsOneWidget);
    expect(find.byType(ColorButton), findsNWidgets(8));
    // Tap red color button
    await tester.tap(find.widgetWithText(ColorButton, 'Red'));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    var node = editor.editorState.getNodeAtPath([1]);
    // Check if the text color is red
    expect(
      node?.allSatisfyInSelection(selection, (delta) {
        return delta.whereType<TextInsert>().every(
              (element) =>
                  element.attributes?[AppFlowyRichTextKeys.textColor] ==
                  Colors.red.toHex(),
            );
      }),
      true,
    );
    // Tap clear color button
    await tester.tap(find.byType(ClearColorButton));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(
      node?.allSatisfyInSelection(selection, (delta) {
        return delta.whereType<TextInsert>().every(
              (element) =>
                  element.attributes?[AppFlowyRichTextKeys.textColor] == null,
            );
      }),
      true,
    );

    // Test background color tab
    await tester.tap(
      find.widgetWithText(
        TabBar,
        AppFlowyEditorL10n.current.backgroundColor,
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    // Tap red color button
    await tester.tap(find.byType(ColorButton).last);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    // Check if the background color is red
    expect(
      node?.allSatisfyInSelection(selection, (delta) {
        return delta.whereType<TextInsert>().every(
              (element) =>
                  element.attributes?[AppFlowyRichTextKeys.backgroundColor] ==
                  Colors.red.withOpacity(0.3).toHex(),
            );
      }),
      true,
    );
    // Tap clear color button
    await tester.tap(find.byType(ClearColorButton));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(
      node?.allSatisfyInSelection(selection, (delta) {
        return delta.whereType<TextInsert>().every(
              (element) =>
                  element.attributes?[AppFlowyRichTextKeys.backgroundColor] ==
                  null,
            );
      }),
      true,
    );
  });
}
