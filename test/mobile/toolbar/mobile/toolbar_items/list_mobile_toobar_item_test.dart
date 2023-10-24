import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../new/infra/testable_editor.dart';
import '../test_helpers/mobile_app_with_toolbar_widget.dart';

void main() {
  testWidgets('listMobileToolbarItem', (WidgetTester tester) async {
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
            listMobileToolbarItem,
          ],
        ),
      ),
    );

    // Tap text decoration toolbar item
    await tester.tap(find.byType(IconButton).first);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // Show its menu and it has 2 buttons
    expect(find.byType(MobileToolbarItemMenu), findsOneWidget);
    expect(
      find.text(AppFlowyEditorL10n.current.bulletedList),
      findsOneWidget,
    );
    expect(
      find.text(AppFlowyEditorL10n.current.numberedList),
      findsOneWidget,
    );

    // Test Bulleted List button
    await tester.tap(
      find.widgetWithText(
        MobileToolbarItemMenuBtn,
        AppFlowyEditorL10n.current.bulletedList,
      ),
    );
    var node = editor.editorState.getNodeAtPath([1]);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(
      node?.type == BulletedListBlockKeys.type,
      true,
    );

    // Test Numbered List button
    await tester.tap(
      find.widgetWithText(
        MobileToolbarItemMenuBtn,
        AppFlowyEditorL10n.current.numberedList,
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    //Get updated node
    node = editor.editorState.getNodeAtPath([1]);
    expect(
      node?.type == NumberedListBlockKeys.type,
      true,
    );
  });
}
