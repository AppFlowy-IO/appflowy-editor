import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import '../infra/test_editor.dart';

void main() {
  group('command_extension.dart', () {
    testWidgets('getTextInSelection w/ multiple nodes', (tester) async {
      final editor = tester.editor
        ..insertTextNode(
          'Welcome',
        )
        ..insertTextNode(
          'to',
        )
        ..insertTextNode(
          'Appflowy 😁',
        );

      await editor.startTesting();

      final selection = Selection(
        start: Position(path: [2], offset: 5),
        end: Position(path: [0], offset: 5),
      );

      await editor.updateSelection(selection);

      final textNodes = editor
          .editorState.service.selectionService.currentSelectedNodes
          .whereType<TextNode>()
          .toList(growable: false);

      final text = editor.editorState.getTextInSelection(
        textNodes.normalized,
        selection.normalized,
      );

      expect(text, 'me\nto\nAppfl');
    });

    testWidgets('getTextInSelection where selection.isSingle', (tester) async {
      final editor = tester.editor
        ..insertTextNode(
          'Welcome',
        )
        ..insertTextNode(
          'to',
        )
        ..insertTextNode(
          'Appflowy 😁',
        );

      await editor.startTesting();

      final selection = Selection(
        start: Position(path: [0], offset: 3),
        end: Position(path: [0]),
      );

      await editor.updateSelection(selection);

      final textNodes = editor
          .editorState.service.selectionService.currentSelectedNodes
          .whereType<TextNode>()
          .toList(growable: false);

      final text = editor.editorState.getTextInSelection(
        textNodes.normalized,
        selection.normalized,
      );

      expect(text, 'Wel');
    });

    testWidgets('getNode throws if node and path are null', (tester) async {
      final editor = tester.editor;
      await editor.startTesting();

      expect(() => editor.editorState.getNode(), throwsA(isA<Exception>()));
    });

    testWidgets('getNode by path', (tester) async {
      final editor = tester.editor
        ..insertTextNode(
          'Welcome',
        )
        ..insertTextNode(
          'to',
        )
        ..insertTextNode(
          'Appflowy 😁',
        );

      await editor.startTesting();

      final node = editor.editorState.getNode(path: [0]) as TextNode;

      expect(node.type, 'text');
      expect((node.delta.first as TextInsert).text, 'Welcome');
    });

    testWidgets('getTextNode throws if textNode and path are null',
        (tester) async {
      final editor = tester.editor;
      await editor.startTesting();

      expect(() => editor.editorState.getTextNode(), throwsA(isA<Exception>()));
    });

    testWidgets('getTextNode by path', (tester) async {
      final editor = tester.editor
        ..insertTextNode(
          'Welcome',
        )
        ..insertTextNode(
          'to',
        )
        ..insertTextNode(
          'Appflowy 😁',
        );

      await editor.startTesting();

      final node = editor.editorState.getTextNode(path: [1]);

      expect(node.type, 'text');
      expect((node.delta.first as TextInsert).text, 'to');
    });

    testWidgets(
        'getSelection throws if selection and selectionService.currentSelection are null',
        (tester) async {
      final editor = tester.editor;
      await editor.startTesting();

      expect(
        () => editor.editorState.getSelection(null),
        throwsA(isA<Exception>()),
      );
    });
  });
}
