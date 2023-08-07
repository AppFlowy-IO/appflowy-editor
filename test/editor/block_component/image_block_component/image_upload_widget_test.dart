import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../new/util/util.dart';

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
}
