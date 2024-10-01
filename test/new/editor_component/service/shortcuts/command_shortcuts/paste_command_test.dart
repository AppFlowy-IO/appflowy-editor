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
  });

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
}
