import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import '../../../../new/infra/testable_editor.dart';
import '../test_helpers/mobile_app_with_toolbar_widget.dart';

void main() {
  testWidgets('textDecorationMobileToolbarItem', (WidgetTester tester) async {
    const text = 'Welcome to Appflowy 😁';
    final editor = tester.editor..addParagraphs(3, initialText: text);
    await editor.startTesting();

    var selection = Selection.single(
      path: [1],
      startOffset: 2,
      endOffset: text.length - 2,
    );

    await editor.updateSelection(selection);
    await tester.pumpWidget(Material(
      child: MobileAppWithToolbarWidget(
        editorState: editor.editorState,
        toolbarItems: [
          textDecorationMobileToolbarItem,
        ],
      ),
    ));

    // Tap text decoration toolbar item
    await tester.tap(find.byType(IconButton).first);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // Show its menu and it has 4 buttons
    expect(find.byType(MobileToolbarItemMenu), findsOneWidget);
    expect(find.text('Bold'), findsOneWidget);
    expect(find.text('Italic'), findsOneWidget);
    expect(find.text('Underline'), findsOneWidget);
    expect(find.text('Strikethrough'), findsOneWidget);

    // Test bold button
    await tester.tap(find.widgetWithText(MobileToolbarItemMenuBtn, 'Bold'));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    final node = editor.editorState.getNodeAtPath([1]);
    expect(
      node?.allSatisfyInSelection(selection, (delta) {
        return delta.whereType<TextInsert>().every(
              (element) => element.attributes?[FlowyRichTextKeys.bold] == true,
            );
      }),
      true,
    );

    // Test Italic button
    await tester.tap(find.widgetWithText(MobileToolbarItemMenuBtn, 'Italic'));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(
      node?.allSatisfyInSelection(selection, (delta) {
        return delta.whereType<TextInsert>().every(
              (element) =>
                  element.attributes?[FlowyRichTextKeys.italic] == true,
            );
      }),
      true,
    );

    // Test Underline button
    await tester
        .tap(find.widgetWithText(MobileToolbarItemMenuBtn, 'Underline'));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(
      node?.allSatisfyInSelection(selection, (delta) {
        return delta.whereType<TextInsert>().every(
              (element) =>
                  element.attributes?[FlowyRichTextKeys.underline] == true,
            );
      }),
      true,
    );

    // Test Strikethrough button
    await tester
        .tap(find.widgetWithText(MobileToolbarItemMenuBtn, 'Strikethrough'));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(
      node?.allSatisfyInSelection(selection, (delta) {
        return delta.whereType<TextInsert>().every(
              (element) =>
                  element.attributes?[FlowyRichTextKeys.strikethrough] == true,
            );
      }),
      true,
    );
  });
}
