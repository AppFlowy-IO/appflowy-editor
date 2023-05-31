import 'package:flutter_test/flutter_test.dart';
import '../new/infra/testable_editor.dart';

void main() {
  group('AppFlowyEditor tests', () {
    testWidgets('without autoFocus', (tester) async {
      final editor = tester.editor..addParagraph(initialText: 'Hello');
      await editor.startTesting(autoFocus: false);
      final selection = editor.selection;
      expect(selection != null, false);
      await editor.dispose();
    });

    testWidgets('with autoFocus', (tester) async {
      final editor = tester.editor..addParagraph(initialText: 'Hello');
      await editor.startTesting(autoFocus: true);
      final selection = editor.selection;
      expect(selection != null, true);
      await editor.dispose();
    });
  });
}
