import 'dart:convert';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../new/util/util.dart';
import '../../../test_helper.dart';

void main() {
  group('InsertImage', () {
    test('insertImageNode', () async {
      const initialText = "Welcome to AppFlowy!";
      final document = Document.blank().addParagraph(initialText: initialText);
      final editorState = EditorState(document: document);
      expect(editorState.document.root.children.length, 1);

      editorState.updateSelectionWithReason(
        Selection.collapsed(Position(path: [0], offset: initialText.length)),
      );

      await editorState.insertImageNode('https://appflowy.io/image.jpg');
      expect(editorState.document.root.children.length, 2);
    });
  });

  group('ImageWidget', () {
    testWidgets('invalidURL', (tester) async {
      await tester.buildAndPump(
        UploadImageMenu(
          onSubmitted: (String text) {},
          onUpload: (String text) {},
        ),
      );

      final urlButtonFinder = find.widgetWithText(Tab, 'URL Image');
      expect(urlButtonFinder, findsOneWidget);
      await tester.tap(urlButtonFinder);
      await tester.pumpAndSettle();
      final urlFieldFinder = find.widgetWithText(TextField, 'URL');
      expect(urlFieldFinder, findsOneWidget);
      await tester.enterText(urlFieldFinder, 'Hello World!');
      final uploadButtonFinder = find.text('Upload');
      expect(uploadButtonFinder, findsOneWidget);
      await tester.tap(uploadButtonFinder);
      await tester.pumpAndSettle();
      final incorrectLinkFinder = find.text('Incorrect Link');
      expect(incorrectLinkFinder, findsOneWidget);
    });

    testWidgets('imageLoadError', (tester) async {
      await AppFlowyEditorLocalizations.load(
        const Locale.fromSubtags(languageCode: 'en'),
      );

      await tester.buildAndPump(
        AppFlowyEditor(
          editorState: EditorState(
            document: Document.fromJson(
              json.decode(
                '{"document":{"type":"page","children":[{"type":"heading","data":{"level":2,"delta":[]}},{"type":"image","data":{"url":"https://127.0.0.1/image/not/exist.jpg","align":"center"}}]}}',
              ),
            ),
          ),
        ),
      );
      final couldNotLoadFinder = find.text('Could not load the image');
      expect(couldNotLoadFinder, findsOneWidget);
    });
  });
}
