import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/ime/delta_input_impl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../new/infra/testable_editor.dart';

void main() {
  group('onNonTextUpdate', () {
    // Pro-performa test
    test('call', () async {
      await onNonTextUpdate(
        const TextEditingDeltaNonTextUpdate(
          oldText: 'AppFlowy',
          selection: TextSelection(baseOffset: 0, extentOffset: 3),
          composing: TextRange(start: 0, end: 3),
        ),
        EditorState.blank(),
        [],
      );
    });

    testWidgets('handles Android IME select all as document select all',
        (tester) async {
      const text = 'AppFlowy';
      final editor = tester.editor..addParagraphs(3, initialText: text);
      await editor.startTesting();
      await editor.updateSelection(
        Selection.collapsed(Position(path: [1], offset: 3)),
      );
      final oldText = List.filled(3, text).join('\n');

      final handled = await handleAndroidNonTextUpdate(
        TextEditingDeltaNonTextUpdate(
          oldText: oldText,
          selection: TextSelection(
            baseOffset: 0,
            extentOffset: oldText.length,
          ),
          composing: TextRange.empty,
        ),
        editor.editorState,
      );

      expect(handled, true);
      expect(
        editor.selection,
        Selection(
          start: Position(path: [0]),
          end: Position(path: [2], offset: text.length),
        ),
      );
      expect(
        editor.editorState.selectionUpdateReason,
        SelectionUpdateReason.selectAll,
      );

      await editor.dispose();
    });
  });
}
