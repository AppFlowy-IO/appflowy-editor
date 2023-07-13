import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import '../../../../new/infra/testable_editor.dart';
import '../test_helpers/mobile_app_with_toolbar_widget.dart';

void main() {
  testWidgets('codeMobileToolbarItem', (WidgetTester tester) async {
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
            codeMobileToolbarItem,
          ],
        ),
      ),
    );

    // Tap code toolbar item
    final codeBtn = find.byType(IconButton).first;
    await tester.tap(codeBtn);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    // Check if the text becomes code format
    final node = editor.editorState.getNodeAtPath([1]);
    expect(
      node?.allSatisfyInSelection(selection, (delta) {
        return delta.whereType<TextInsert>().every(
              (element) =>
                  element.attributes?[AppFlowyRichTextKeys.code] == true,
            );
      }),
      true,
    );
  });
}
