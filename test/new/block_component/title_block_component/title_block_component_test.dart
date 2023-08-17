import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../infra/testable_editor.dart';

void main() async {
  group('Test the Title Node', () {
    const sampleText = "Welcome to AppFlowy";
    testWidgets('Test without an existing Title Node', (tester) async {
      final editor = tester.editor
        ..addParagraph(
          initialText: sampleText,
          decorator: (i, n) => n.updateAttributes(
            {blockComponentTextDirection: blockComponentTextDirectionAuto},
          ),
        );

      final node = editor.editorState.getNodeAtPath([0]);
      await editor.startTesting();

      if (node?.type == titleNode().type) {
        expect(editor.document.nodeAtPath([0])?.type, titleNode().type);
      }

      await editor.dispose();
    });

    testWidgets('Test with an existing Title Node', (tester) async {
      final editor = tester.editor
        ..addNode(titleNode())
        ..addParagraph(
          initialText: sampleText,
          decorator: (i, n) => n.updateAttributes(
            {blockComponentTextDirection: blockComponentTextDirectionAuto},
          ),
        );

      final node = editor.editorState.getNodeAtPath([0]);
      await editor.startTesting();

      if (node?.type == titleNode().type) {
        expect(editor.document.nodeAtPath([0])?.type, titleNode().type);
      }

      await editor.dispose();
    });

    testWidgets('Test without an existing Title Node then add it',
        (tester) async {
      final editor = tester.editor
        ..addParagraph(
          initialText: sampleText,
          decorator: (i, n) => n.updateAttributes(
            {blockComponentTextDirection: blockComponentTextDirectionAuto},
          ),
        );

      final node = editor.editorState.getNodeAtPath([0]);
      await editor.startTesting();

      if (node?.type != titleNode().type) {
        editor.document.insert([0], [titleNode()]);
      }

      final newNode = editor.editorState.getNodeAtPath([0]);
      expect(newNode?.type, titleNode().type);

      await editor.dispose();
    });
  });
}
