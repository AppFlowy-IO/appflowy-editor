import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import '../../../../new/infra/testable_editor.dart';
import '../test_helpers/mobile_app_with_toolbar_widget.dart';

void main() {
  testWidgets('linkMobileToolbarItem', (WidgetTester tester) async {
    if (PlatformExtension.isDesktopOrWeb) {
      return;
    }

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
            linkMobileToolbarItem,
          ],
        ),
      ),
    );

    // Tap link toolbar item
    await tester.tap(find.byType(IconButton).first);
    await tester.pumpAndSettle();
    // Show its menu
    expect(find.byType(MobileToolbarItemMenu), findsOneWidget);

    // Enter link address
    const linkAddress = 'www.google.com';
    final textField = find.byType(TextField);
    await tester.enterText(textField, linkAddress);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // Check if the text becomes a link
    final node = editor.editorState.getNodeAtPath([1]);
    expect(
      node?.allSatisfyInSelection(selection, (delta) {
        return delta.whereType<TextInsert>().every(
              (element) =>
                  element.attributes?[AppFlowyRichTextKeys.href] == linkAddress,
            );
      }),
      true,
    );
  });
}
