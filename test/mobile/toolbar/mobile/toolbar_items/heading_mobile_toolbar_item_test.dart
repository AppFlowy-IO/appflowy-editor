import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../new/infra/testable_editor.dart';
import '../test_helpers/mobile_app_with_toolbar_widget.dart';

void main() {
  testWidgets('headingMobileToolbarItem', (WidgetTester tester) async {
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
            headingMobileToolbarItem,
          ],
        ),
      ),
    );

    // Tap heading toolbar item
    await tester.tap(find.byType(IconButton).first);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // Show its menu and it has 3 buttons
    expect(find.byType(MobileToolbarItemMenu), findsOneWidget);
    expect(
      find.text(AppFlowyEditorL10n.current.mobileHeading1),
      findsOneWidget,
    );
    expect(
      find.text(AppFlowyEditorL10n.current.mobileHeading2),
      findsOneWidget,
    );
    expect(
      find.text(AppFlowyEditorL10n.current.mobileHeading3),
      findsOneWidget,
    );

    // Test Heading 1 button
    await tester.tap(
      find.widgetWithText(
        MobileToolbarItemMenuBtn,
        AppFlowyEditorL10n.current.mobileHeading1,
      ),
    );
    var node = editor.editorState.getNodeAtPath([1]);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(
      node?.type == HeadingBlockKeys.type &&
          node?.attributes[HeadingBlockKeys.level] == 1,
      true,
    );

    // Test Heading 2 button
    await tester.tap(
      find.widgetWithText(
        MobileToolbarItemMenuBtn,
        AppFlowyEditorL10n.current.mobileHeading2,
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    //Get updated node
    node = editor.editorState.getNodeAtPath([1]);
    expect(
      node?.type == HeadingBlockKeys.type &&
          node?.attributes[HeadingBlockKeys.level] == 2,
      true,
    );

    // Test Heading 3 button
    await tester.tap(
      find.widgetWithText(
        MobileToolbarItemMenuBtn,
        AppFlowyEditorL10n.current.mobileHeading3,
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    //Get updated node
    node = editor.editorState.getNodeAtPath([1]);
    expect(
      node?.type == HeadingBlockKeys.type &&
          node?.attributes[HeadingBlockKeys.level] == 3,
      true,
    );
  });
}
