import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/ime/delta_input_impl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../new/util/util.dart';

void main() {
  group('DeltaInputOnDelete', () {
    test('onDelete', () async {
      final document =
          Document.blank().addParagraphs(4, initialText: 'AppFlowy!');

      final editorState = EditorState(document: document);
      editorState.selection = Selection.collapsed(Position(path: [0]));

      await onDelete(
        const TextEditingDeltaDeletion(
          oldText: 'AppFlowy!',
          deletedRange: TextRange(start: 0, end: 3),
          selection: TextSelection(baseOffset: 0, extentOffset: 0),
          composing: TextRange(start: 0, end: 0),
        ),
        editorState,
      );

      expect(document.first!.delta!.toPlainText(), 'Flowy!');
    });
  });
}
