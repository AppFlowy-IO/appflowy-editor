import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../infra/testable_editor.dart';

const _hyphen = '-';
const _emDash = '—'; // This is an em dash

void main() async {
  group('format_double_hyphen.dart', () {
    testWidgets('two dashes to em dash', (tester) async {
      final editor = tester.editor..addEmptyParagraph();
      await editor.startTesting();

      await editor.updateSelection(Selection.collapsed(Position(path: [0])));

      await editor.ime.typeText(_hyphen);
      await editor.ime.typeText(_hyphen);

      final delta = editor.nodeAtPath([0])!.delta!;
      expect(delta.length, 1);
      expect(delta.toPlainText(), _emDash);

      await editor.dispose();
    });

    testWidgets('two dashes to em dash with selection', (tester) async {
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

      await editor.ime.typeText(_hyphen);

      final delta = editor.nodeAtPath([0])!.delta!;
      expect(delta.length, 1);
      expect(delta.toPlainText(), _emDash);

      await editor.dispose();
    });

    testWidgets('em dash + dash to divider', (tester) async {
      final editor = tester.editor..addParagraph(initialText: _emDash);
      await editor.startTesting();

      await editor.updateSelection(
        Selection.collapsed(Position(path: [0], offset: 1)),
      );

      await editor.ime.typeText(_hyphen);

      final node = editor.nodeAtPath([0]);
      expect(node!.type, DividerBlockKeys.type);

      await editor.dispose();
    });
  });
}
