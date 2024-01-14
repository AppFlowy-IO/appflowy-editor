import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../infra/testable_editor.dart';

const _hyphen = '-';
const _greater = '>';
const _singleArrow = '→';

void main() async {
  group('format_arrow_character.dart', () {
    testWidgets('hyphen + greater to single arrow', (tester) async {
      final editor = tester.editor..addEmptyParagraph();
      await editor.startTesting();

      await editor.updateSelection(Selection.collapsed(Position(path: [0])));

      await editor.ime.typeText(_hyphen);
      await editor.ime.typeText(_greater);

      final delta = editor.nodeAtPath([0])!.delta!;
      expect(delta.length, 1);
      expect(delta.toPlainText(), _singleArrow);

      await editor.dispose();
    });

    testWidgets('hyphen + greater to single arrow with selection',
        (tester) async {
      const welcome = 'Welcome';
      const initialText = '$_hyphen$welcome';

      final editor = tester.editor..addParagraph(initialText: initialText);
      await editor.startTesting();

      await editor.updateSelection(
        Selection.single(
          path: [0],
          startOffset: 1,
          endOffset: initialText.length,
        ),
      );

      await editor.ime.typeText(_greater);

      final delta = editor.nodeAtPath([0])!.delta!;
      expect(delta.length, 1);
      expect(delta.toPlainText(), _singleArrow);

      await editor.dispose();
    });
  });
}
