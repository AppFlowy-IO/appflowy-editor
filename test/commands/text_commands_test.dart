import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../infra/test_editor.dart';

void main() {
  group('TextCommands extension tests', () {
    testWidgets('insertText', (tester) async {
      final editor = tester.editor
        ..insertEmptyTextNode()
        ..insertTextNode('World');
      await editor.startTesting();

      editor.editorState.insertText(0, 'Hello', path: [0]);
      await tester.pumpAndSettle();

      expect(
        (editor.editorState.getTextNode(path: [0]).delta.first as TextInsert)
            .text,
        'Hello',
      );
    });

    testWidgets('insertTextAtCurrentSelection', (tester) async {
      final editor = tester.editor..insertTextNode('Helrld!');
      await editor.startTesting();

      final selection = Selection(
        start: Position(path: [0], offset: 3),
        end: Position(path: [0], offset: 3),
      );

      await editor.updateSelection(selection);

      editor.editorState.insertTextAtCurrentSelection('lo Wo');
      await tester.pumpAndSettle();

      expect(
        (editor.editorState.getTextNode(path: [0]).delta.first as TextInsert)
            .text,
        'Hello World!',
      );
    });

    testWidgets('formatText', (tester) async {
      final editor = tester.editor..insertTextNode('Hello');
      await editor.startTesting();

      final selection = Selection(
        start: Position(path: [0]),
        end: Position(path: [0], offset: 5),
      );

      await editor.updateSelection(selection);

      editor.editorState
          .formatText(null, {BuiltInAttributeKey.bold: true}, path: [0]);
      await tester.pumpAndSettle();

      final textNode = editor.editorState.getTextNode(path: [0]);
      final textInsert = textNode.delta.first as TextInsert;

      expect(textInsert.text, 'Hello');
      expect(textInsert.attributes?[BuiltInAttributeKey.bold], true);
    });

    testWidgets('formatTextWithBuiltInAttribute w/ Partial Style Key',
        (tester) async {
      final editor = tester.editor..insertTextNode('Hello');
      await editor.startTesting();

      final selection = Selection(
        start: Position(path: [0]),
        end: Position(path: [0], offset: 5),
      );

      await editor.updateSelection(selection);

      editor.editorState.formatTextWithBuiltInAttribute(
        BuiltInAttributeKey.underline,
        {BuiltInAttributeKey.underline: true},
        path: [0],
      );
      await tester.pumpAndSettle();

      final textNode = editor.editorState.getTextNode(path: [0]);
      final textInsert = textNode.delta.first as TextInsert;

      expect(textInsert.text, 'Hello');
      expect(textInsert.attributes?[BuiltInAttributeKey.underline], true);
    });

    testWidgets('formatTextWithBuiltInAttribute w/ Global Style Key',
        (tester) async {
      final editor = tester.editor
        ..insertTextNode(
          'Hello',

          /// Formatting global style over another global style,
          /// will remove the existing one before adding the new one
          attributes: {BuiltInAttributeKey.checkbox: true},
        );
      await editor.startTesting();

      editor.editorState.formatTextWithBuiltInAttribute(
        BuiltInAttributeKey.heading,
        {BuiltInAttributeKey.heading: BuiltInAttributeKey.h1},
        path: [0],
      );
      await tester.pumpAndSettle();

      final textNode = editor.editorState.getTextNode(path: [0]);
      final textInsert = textNode.delta.first as TextInsert;

      expect(textInsert.text, 'Hello');
      expect(textNode.attributes.heading, BuiltInAttributeKey.h1);
      expect(textNode.attributes['subtype'], BuiltInAttributeKey.heading);
    });

    testWidgets('formatTextToCheckbox', (tester) async {
      final editor = tester.editor..insertTextNode('TextNode to Checkbox');
      await editor.startTesting();

      editor.editorState.formatTextToCheckbox(false, path: [0]);
      await tester.pumpAndSettle();

      final checkboxNode = editor.editorState.getNode(path: [0]);

      expect(checkboxNode.attributes.check, false);
      expect(checkboxNode.attributes['subtype'], BuiltInAttributeKey.checkbox);
    });

    testWidgets('formatLinkInText', (tester) async {
      const href = "https://appflowy.io/";

      final editor = tester.editor..insertTextNode('TextNode to Link');
      await editor.startTesting();

      final selection = Selection(
        start: Position(path: [0]),
        end: Position(path: [0], offset: 5),
      );

      await editor.updateSelection(selection);

      editor.editorState.formatLinkInText(href, path: [0]);
      await tester.pumpAndSettle();

      final textNode = editor.editorState.getTextNode(path: [0]);
      final textInsert = textNode.delta.first as TextInsert;

      expect(textInsert.attributes?[BuiltInAttributeKey.href], href);
    });

    testWidgets('insertNewLine', (tester) async {
      final editor = tester.editor;
      await editor.startTesting();

      expect(editor.documentLength, 0);

      editor.editorState.insertNewLine(path: [0]);
      await tester.pumpAndSettle();

      expect(editor.documentLength, 1);
    });

    testWidgets('insertNewLine without path', (tester) async {
      final editor = tester.editor..insertTextNode('Hello World');
      await editor.startTesting();

      expect(editor.documentLength, 1);

      final selection = Selection(
        start: Position(path: [0], offset: 5),
        end: Position(path: [0], offset: 5),
      );

      await editor.updateSelection(selection);

      editor.editorState.insertNewLine(path: null);
      await tester.pumpAndSettle();

      expect(editor.documentLength, 2);

      final textNode = editor.editorState.getTextNode(path: [0]);
      final textInsert = textNode.delta.first as TextInsert;

      expect(textInsert.text, 'Hello World');
    });

    testWidgets('insertNewLineAtCurrentSelection', (tester) async {
      final editor = tester.editor..insertTextNode('HelloWorld');
      await editor.startTesting();

      final selection = Selection(
        start: Position(path: [0], offset: 5),
        end: Position(path: [0], offset: 5),
      );

      await editor.updateSelection(selection);

      expect(editor.documentLength, 1);

      editor.editorState.insertNewLineAtCurrentSelection();
      await tester.pumpAndSettle();

      expect(editor.documentLength, 2);

      final firstTextNode = editor.editorState.getTextNode(path: [0]);
      final firstTextInsert = firstTextNode.delta.first as TextInsert;
      expect(firstTextInsert.text, 'Hello');

      final secondTextNode = editor.editorState.getTextNode(path: [1]);
      final secondTextInsert = secondTextNode.delta.first as TextInsert;

      expect(secondTextInsert.text, 'World');
    });
  });
}
