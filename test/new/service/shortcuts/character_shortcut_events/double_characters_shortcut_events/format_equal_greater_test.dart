import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../infra/testable_editor.dart';

const _greater = '>';
const _equals = '=';
const _arrow = '⇒';

void main() async {
  group('format_equal_greater.dart', () {
    testWidgets('= + > to ⇒ in empty paragraph', (tester) async {
      final editor = tester.editor..addEmptyParagraph();
      await editor.startTesting();

      await editor.updateSelection(Selection.collapsed(Position(path: [0])));

      await editor.ime.typeText(_equals);
      await editor.ime.typeText(_greater);

      final delta = editor.nodeAtPath([0])!.delta!;
      expect(delta.length, 1);
      expect(delta.toPlainText(), _arrow);

      await editor.dispose();
    });

    testWidgets('= + > to ⇒ in non-empty paragraph, undo, redo',
        (tester) async {
      const text = 'Hello World';
      final editor = tester.editor..addParagraph(initialText: text);
      await editor.startTesting();

      await editor.updateSelection(
        Selection.collapsed(
          Position(
            path: [0],
            offset: text.length,
          ),
        ),
      );

      await editor.ime.typeText(_equals);
      await editor.ime.typeText(_greater);

      Delta delta = editor.nodeAtPath([0])!.delta!;
      expect(delta.toPlainText(), text + _arrow);

      undoCommand.execute(editor.editorState);
      await tester.pumpAndSettle();

      delta = editor.nodeAtPath([0])!.delta!;
      expect(delta.toPlainText(), text + _equals);

      undoCommand.execute(editor.editorState);
      await tester.pumpAndSettle();

      delta = editor.nodeAtPath([0])!.delta!;
      expect(delta.toPlainText(), text);

      await editor.dispose();
    });
  });
}
