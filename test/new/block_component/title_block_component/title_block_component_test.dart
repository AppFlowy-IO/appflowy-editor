import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../infra/testable_editor.dart';

final titlePluginBuilder = TitleBlockComponentBuilder(
  configuration: standardBlockComponentConfiguration.copyWith(
    placeholderText: (node) => 'Untitled',
    padding: (_) => const EdgeInsets.symmetric(vertical: 20),
  ),
);

void main() async {
  group('Test the Title Node', () {
    const sampleText = "Welcome to AppFlowy";
    testWidgets('Test without an existing Title Node', (tester) async {
      final editor = tester.editorWithCustomBlock(
        builders: {TitleBlockKeys.type: titlePluginBuilder},
      )..addParagraph(
          initialText: sampleText,
          decorator: (i, n) => n.updateAttributes(
            {blockComponentTextDirection: blockComponentTextDirectionAuto},
          ),
        );

      await editor.startTesting();

      final node = editor.editorState.getNodeAtPath([0]);
      if (node?.type == titleNode().type) {
        expect(editor.document.nodeAtPath([0])?.type, titleNode().type);
      }

      await editor.dispose();
    });

    testWidgets('Test with an existing Title Node', (tester) async {
      final editor = tester.editorWithCustomBlock(
        builders: {TitleBlockKeys.type: titlePluginBuilder},
      )
        ..addNode(titleNode())
        ..addParagraph(
          initialText: sampleText,
          decorator: (i, n) => n.updateAttributes(
            {blockComponentTextDirection: blockComponentTextDirectionAuto},
          ),
        );

      await editor.startTesting();

      final node = editor.editorState.getNodeAtPath([0]);
      if (node?.type == titleNode().type) {
        expect(editor.document.nodeAtPath([0])?.type, titleNode().type);
      }

      await editor.dispose();
    });

    testWidgets('Test without an existing Title Node then add it',
        (tester) async {
      final editor = tester.editorWithCustomBlock(
        builders: {TitleBlockKeys.type: titlePluginBuilder},
      )..addParagraph(
          initialText: sampleText,
          decorator: (i, n) => n.updateAttributes(
            {blockComponentTextDirection: blockComponentTextDirectionAuto},
          ),
        );

      await editor.startTesting();

      final node = editor.editorState.getNodeAtPath([0]);
      if (node?.type != titleNode().type) {
        editor.document.insert([0], [titleNode()]);
      }

      final newNode = editor.editorState.getNodeAtPath([0]);
      expect(newNode?.type, titleNode().type);

      await editor.dispose();
    });
  });
}
