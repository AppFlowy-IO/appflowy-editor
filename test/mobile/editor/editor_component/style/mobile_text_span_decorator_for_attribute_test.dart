import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../new/infra/testable_editor.dart';

void main() {
  group('mobile_text_span_decorator_for_attribute.dart', () {
    group('Link attribute', () {
      testWidgets(
        'Check if link can be launched through [safeLaunchUrl] method',
        (widgetTester) async {
          const text = 'Appflowy website';
          const address = 'https://appflowy.com/';
          final editor = widgetTester.editor;
          //create a link [Appflowy website](https://appflowy.com/)
          editor.addParagraph(
            builder: (index) => Delta()
              ..insert(text, attributes: {BuiltInAttributeKey.href: address}),
          );
          await editor.startTesting(inMobile: true, editable: false);
          await widgetTester.pumpAndSettle();

          final finder = find.text(text, findRichText: true);
          expect(finder, findsOneWidget);
          await widgetTester.tap(finder);
          await widgetTester.pumpAndSettle();

          // test the method only
          expect(() => safeLaunchUrl(address), returnsNormally);
        },
      );
      testWidgets(
        'Show edit link dialog after long tap the link',
        (WidgetTester tester) async {
          const text = 'Appflowy website';
          const address = 'https://appflowy.com/';
          final editor = tester.editor;

          //create a link [Appflowy website](https://appflowy.com/)
          editor.addParagraph(
            builder: (index) => Delta()
              ..insert(text, attributes: {BuiltInAttributeKey.href: address}),
          );
          await editor.startTesting(inMobile: true, editable: false);
          await tester.pumpAndSettle();

          final finder = find.text(text, findRichText: true);
          expect(finder, findsOneWidget);
          await tester.longPress(
            finder,
          );
          await tester.pumpAndSettle();
          expect(find.byType(AlertDialog), findsOneWidget);
        },
      );
      testWidgets(
        'Show error prompt when input is empty',
        (WidgetTester tester) async {
          const text = 'Appflowy website';
          const address = 'https://appflowy.com/';
          final editor = tester.editor;

          //create a link [Appflowy website](https://appflowy.com/)
          editor.addParagraph(
            builder: (index) => Delta()
              ..insert(text, attributes: {BuiltInAttributeKey.href: address}),
          );
          await editor.startTesting(inMobile: true, editable: false);
          await tester.pumpAndSettle();

          final finder = find.text(text, findRichText: true);
          expect(finder, findsOneWidget);
          await tester.longPress(
            finder,
          );
          await tester.enterText(
            find.byKey(const Key('Text TextFormField')),
            '',
          );
          await tester.enterText(
            find.byKey(const Key('Url TextFormField')),
            '',
          );
          await tester.tap(
            find.widgetWithText(
              TextButton,
              AppFlowyEditorL10n.current.done,
            ),
          );
          await tester.pumpAndSettle(const Duration(seconds: 1));
          // show error prompt
          expect(
            find.text(AppFlowyEditorL10n.current.linkTextHint),
            findsOneWidget,
          );
          expect(
            find.text(AppFlowyEditorL10n.current.linkAddressHint),
            findsOneWidget,
          );
        },
      );
      testWidgets(
        'Change the link info correctly by link edit menu',
        (WidgetTester tester) async {
          const text = 'Appflowy website';
          const text2 = 'Appflowy website 2';
          const address = 'https://appflowy.com/';
          const address2 = 'https://appflowy.io/';
          final editor = tester.editor;

          //create a link [Appflowy website](https://appflowy.com/)
          editor.addParagraph(
            builder: (index) => Delta()
              ..insert(text, attributes: {BuiltInAttributeKey.href: address}),
          );
          await editor.startTesting(inMobile: true);
          await tester.pumpAndSettle();

          final finder = find.text(text, findRichText: true);
          expect(finder, findsOneWidget);
          await tester.longPress(
            finder,
          );
          await tester.enterText(
            find.byKey(const Key('Text TextFormField')),
            text2,
          );
          await tester.enterText(
            find.byKey(const Key('Url TextFormField')),
            address2,
          );
          await tester.tap(
            find.widgetWithText(
              TextButton,
              AppFlowyEditorL10n.current.done,
            ),
          );
          await tester.pumpAndSettle(const Duration(seconds: 1));

          var selection = Selection.single(
            path: [0],
            startOffset: 0,
            endOffset: text2.length,
          );
          var node = editor.editorState.getNodesInSelection(selection);
          // link is changed
          expect(
            node.allSatisfyInSelection(selection, (delta) {
              return delta.whereType<TextInsert>().every(
                    (element) =>
                        element.attributes?[BuiltInAttributeKey.href] ==
                        address2,
                  );
            }),
            true,
          );
        },
      );
      testWidgets(
        'Remove the link successfully by link edit menu',
        (WidgetTester tester) async {
          const text = 'Appflowy website';
          const address = 'https://appflowy.com/';
          final editor = tester.editor;

          //create a link [Appflowy website](https://appflowy.com/)
          editor.addParagraph(
            builder: (index) => Delta()
              ..insert(text, attributes: {BuiltInAttributeKey.href: address}),
          );
          await editor.startTesting(inMobile: true);
          await tester.pumpAndSettle();

          final finder = find.text(text, findRichText: true);
          expect(finder, findsOneWidget);
          await tester.longPress(
            finder,
          );
          // tap remove button
          await tester.tap(
            find.widgetWithText(
              TextButton,
              AppFlowyEditorL10n.current.removeLink,
            ),
          );
          await tester.pumpAndSettle(const Duration(seconds: 1));
          //dialog is closed
          expect(find.byType(AlertDialog), findsNothing);

          var selection = Selection.single(
            path: [0],
            startOffset: 0,
            endOffset: text.length,
          );
          var node = editor.editorState.getNodesInSelection(selection);
          // link is removed
          expect(
            node.allSatisfyInSelection(selection, (delta) {
              return delta.whereType<TextInsert>().every(
                    (element) =>
                        element.attributes?[BuiltInAttributeKey.href] == null,
                  );
            }),
            true,
          );
        },
      );
      testWidgets(
        'Edit link menu disappeaar after tap outside the menu',
        (WidgetTester tester) async {
          const text = 'Appflowy website';
          const address = 'https://appflowy.com/';
          final editor = tester.editor;

          //create a link [Appflowy website](https://appflowy.com/)
          editor.addParagraph(
            builder: (index) => Delta()
              ..insert(text, attributes: {BuiltInAttributeKey.href: address}),
          );
          await editor.startTesting(inMobile: true, editable: false);
          await tester.pumpAndSettle();

          final finder = find.text(text, findRichText: true);
          expect(finder, findsOneWidget);
          await tester.longPress(
            finder,
          );
          expect(find.byType(AlertDialog), findsOneWidget);
          await tester.tapAt(const Offset(1, 1));
          await tester.pumpAndSettle(const Duration(seconds: 1));
          expect(find.byType(AlertDialog), findsNothing);
        },
      );
    });
  });
}
