import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import '../../../../new/infra/testable_editor.dart';
import '../test_helpers/mobile_app_with_toolbar_widget.dart';

void main() {
  testWidgets('quoteMobileToolbarItem', (WidgetTester tester) async {
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
            quoteMobileToolbarItem,
          ],
        ),
      ),
    );

    // Tap quote toolbar item
    final quoteBtn = find.byType(IconButton).first;
    await tester.tap(quoteBtn);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    // Check if the text becomes quote node
    final node = editor.editorState.getNodeAtPath([1]);
    expect(
      node?.type == QuoteBlockKeys.type,
      true,
    );
  });
}
