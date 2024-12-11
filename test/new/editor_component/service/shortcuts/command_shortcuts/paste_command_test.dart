import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../new/infra/testable_editor.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('paste command', () {
    // Test case: Paste single line text
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

    // Test case: Paste multiple nodes that start with non-delta node
    testWidgets('paste multiple nodes that start with non-delta node',
        (tester) async {
      const text = 'Hello World';
      final editor = tester.editor..addParagraph(initialText: text);
      await editor.startTesting();

      // paste the context after the text
      await editor.updateSelection(
        Selection.collapsed(Position(path: [0], offset: text.length)),
      );
      const pastedText = 'pasted text';
      editor.editorState.pasteMultiLineNodes([
        imageNode(url: ''),
        paragraphNode(text: pastedText),
      ]);
      await tester.pumpAndSettle();

      expect(editor.nodeAtPath([0])!.delta!.toPlainText(), text);
      expect(editor.nodeAtPath([1])!.type, ImageBlockKeys.type);
      expect(editor.nodeAtPath([2])!.delta!.toPlainText(), pastedText);
    });

    // Test case: Paste multiple nodes that start with delta node
    testWidgets('paste multiple nodes that start with delta node',
        (tester) async {
      const text = 'Hello World';
      final editor = tester.editor..addParagraph(initialText: text);
      await editor.startTesting();

      // paste the context after the text
      await editor.updateSelection(
        Selection.collapsed(Position(path: [0], offset: text.length)),
      );
      const pastedText = 'pasted text';
      editor.editorState.pasteMultiLineNodes([
        paragraphNode(text: pastedText),
        imageNode(url: ''),
      ]);
      await tester.pumpAndSettle();

      expect(editor.nodeAtPath([0])!.delta!.toPlainText(), text + pastedText);
      expect(editor.nodeAtPath([1])!.type, ImageBlockKeys.type);
    });

    // Test case: Paste plain text containing a URL
    testWidgets('paste plain text containing URL', (tester) async {
      final editor = tester.editor..addEmptyParagraph();
      await editor.startTesting();
      await editor.updateSelection(Selection.collapsed(Position(path: [0])));

      const text = 'Visit https://example.com for details';
      AppFlowyClipboard.mockSetData(
        const AppFlowyClipboardData(text: text),
      );
      pasteCommand.execute(editor.editorState);
      await tester.pumpAndSettle();

      expect(
        editor.nodeAtPath([0])!.delta!.toPlainText(),
        text,
      );

      final delta = editor.nodeAtPath([0])!.delta!;
      expect(delta.toJson()[0]['insert'], 'Visit ');
      expect(delta.toJson()[1]['attributes']['href'], 'https://example.com');

      await editor.dispose();
    });

    // Test case: Paste plain text containing a phone number
    testWidgets('paste plain text containing phone number', (tester) async {
      final editor = tester.editor..addEmptyParagraph();
      await editor.startTesting();
      await editor.updateSelection(Selection.collapsed(Position(path: [0])));

      const text = '+1234567890';
      AppFlowyClipboard.mockSetData(
        const AppFlowyClipboardData(text: text),
      );
      pasteCommand.execute(editor.editorState);
      await tester.pumpAndSettle();

      final delta = editor.nodeAtPath([0])!.delta!;
      expect(delta.toJson()[0]['attributes']['href'], 'tel:+1234567890');
      expect(delta.toPlainText(), text);

      await editor.dispose();
    });

    // Test case: Paste HTML content
    testWidgets('paste HTML content', (tester) async {
      final editor = tester.editor..addEmptyParagraph();
      await editor.startTesting();
      await editor.updateSelection(Selection.collapsed(Position(path: [0])));

      const html = '<p>Hello <strong>World!</strong></p>';
      AppFlowyClipboard.mockSetData(
        const AppFlowyClipboardData(html: html),
      );
      pasteCommand.execute(editor.editorState);
      await tester.pumpAndSettle();

      final delta = editor.nodeAtPath([0])!.delta!;
      expect(delta.toPlainText(), 'Hello World!');
      expect(delta.toJson()[1]['attributes']['bold'], true);

      await editor.dispose();
    });

    // Test case: Paste text without formatting
    testWidgets('paste text without formatting', (tester) async {
      final editor = tester.editor..addParagraph(initialText: 'Existing text');
      await editor.startTesting();
      await editor.updateSelection(
        Selection.collapsed(Position(path: [0], offset: 13)),
      );

      const text = ' Plain text';
      AppFlowyClipboard.mockSetData(
        const AppFlowyClipboardData(text: text),
      );
      pasteTextWithoutFormattingCommand.execute(editor.editorState);
      await tester.pumpAndSettle();

      expect(
        editor.nodeAtPath([0])!.delta!.toPlainText(),
        'Existing text Plain text',
      );
    });
  });
}
