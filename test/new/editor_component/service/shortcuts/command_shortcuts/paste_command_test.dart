import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../new/infra/testable_editor.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('paste command', () {
    testWidgets('paste single line text', (tester) async {
      final editor = tester.editor..addEmptyParagraph();
      await editor.startTesting();
      await editor.updateSelection(Selection.collapsed(Position(path: [0])));

      const text = 'Hello World!';
      AppFlowyClipboard.mockSetData(
        const AppFlowyClipboardData(text: text),
      );
      pasteCommand.execute(editor.editorState);
      await tester.pumpAndSettle();

      expect(editor.nodeAtPath([0])!.delta!.toPlainText(), text);

      await editor.dispose();
    });

    testWidgets('paste multiple lines text', (tester) async {
      final editor = tester.editor..addEmptyParagraph();
      await editor.startTesting();
      await editor.updateSelection(Selection.collapsed(Position(path: [0])));

      const text = 'Hello World!';
      const texts = '''$text
# $text
## $text
### $text
> $text
- $text''';
      AppFlowyClipboard.mockSetData(
        const AppFlowyClipboardData(text: texts),
      );
      pasteCommand.execute(editor.editorState);
      await tester.pumpAndSettle();

      final types = [
        ParagraphBlockKeys.type,
        HeadingBlockKeys.type,
        HeadingBlockKeys.type,
        HeadingBlockKeys.type,
        QuoteBlockKeys.type,
        BulletedListBlockKeys.type,
      ];
      for (var i = 0; i < 6; i++) {
        final node = editor.nodeAtPath([i])!;
        expect(node.delta!.toPlainText(), text);
        expect(types[i], node.type);
      }

      await editor.dispose();
    });
  });
}
