import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../infra/testable_editor.dart';

const _greater = '>';
const _equals = '=';
const _arrow = '⇒'; 

void main() async {
  group('format_equal_greater.dart', () {
    testWidgets('= + > to ⇒', (tester) async {
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
    });
}