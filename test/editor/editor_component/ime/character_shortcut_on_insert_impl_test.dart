import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/ime/delta_input_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('character shortcut on insert', () {
    WidgetsFlutterBinding.ensureInitialized();

    test('call', () async {
      final editorState = EditorState.blank();
      editorState.selection = Selection.collapsed(
        Position(path: [0]),
      );
      await onInsert(
        const TextEditingDeltaInsertion(
          textInserted: ' \n',
          composing: TextRange.empty,
          oldText: '',
          selection: TextSelection.collapsed(offset: 0),
          insertionOffset: 0,
        ),
        editorState,
        [insertNewLine],
      );
      final nodes = editorState.document.root.children;
      expect(nodes.length, 2);
    });
  });
}
