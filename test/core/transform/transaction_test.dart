import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../new/util/util.dart';

void main() async {
  group('transaction.dart', () {
    test('test replaceTexts, textNodes.length == texts.length', () async {
      final document = Document.blank().addParagraphs(
        4,
        initialText: '0123456789',
      );
      final editorState = EditorState(document: document);

      expect(editorState.document.root.children.length, 4);

      final selection = Selection(
        start: Position(path: [0], offset: 4),
        end: Position(path: [3], offset: 4),
      );
      editorState.selection = selection;

      final texts = ['ABC', 'ABC', 'ABC', 'ABC'];
      var nodes = editorState.getNodesInSelection(selection);
      final transaction = editorState.transaction
        ..replaceTexts(nodes, selection, texts);
      await editorState.apply(transaction);

      expect(editorState.document.root.children.length, 4);
      nodes = editorState.getNodesInSelection(selection);
      expect(nodes[0].delta?.toPlainText(), '0123ABC');
      expect(nodes[1].delta?.toPlainText(), 'ABC');
      expect(nodes[2].delta?.toPlainText(), 'ABC');
      expect(nodes[3].delta?.toPlainText(), 'ABC456789');
    });

    test('test replaceTexts, textNodes.length >  texts.length', () async {
      final document = Document.blank().addParagraphs(
        5,
        initialText: '0123456789',
      );
      final editorState = EditorState(document: document);

      expect(editorState.document.root.children.length, 5);

      final selection = Selection(
        start: Position(path: [0], offset: 4),
        end: Position(path: [4], offset: 4),
      );
      editorState.selection = selection;

      final nodes = editorState.getNodesInSelection(selection);
      final texts = ['ABC', 'ABC', 'ABC', 'ABC'];
      final transaction = editorState.transaction
        ..replaceTexts(nodes, selection, texts);
      await editorState.apply(transaction);

      expect(editorState.document.root.children.length, 4);

      expect(editorState.getNodeAtPath([0])?.delta?.toPlainText(), '0123ABC');
      expect(editorState.getNodeAtPath([1])?.delta?.toPlainText(), 'ABC');
      expect(editorState.getNodeAtPath([2])?.delta?.toPlainText(), 'ABC');
      expect(editorState.getNodeAtPath([3])?.delta?.toPlainText(), 'ABC456789');
    });

    test('test replaceTexts, textNodes.length >> texts.length', () async {
      final document = Document.blank().addParagraphs(
        5,
        initialText: '0123456789',
      );
      final editorState = EditorState(document: document);

      expect(editorState.document.root.children.length, 5);
      final selection = Selection(
        start: Position(path: [0], offset: 4),
        end: Position(path: [4], offset: 4),
      );
      editorState.selection = selection;

      final nodes = editorState.getNodesInSelection(selection);
      final texts = ['ABC'];
      final transaction = editorState.transaction
        ..replaceTexts(nodes, selection, texts);
      await editorState.apply(transaction);

      expect(editorState.document.root.children.length, 1);

      expect(
        editorState.getNodeAtPath([0])?.delta?.toPlainText(),
        '0123ABC456789789',
      );
    });

    // testWidgets('test replaceTexts, textNodes.length < texts.length',
    //     (tester) async {
    //   TestWidgetsFlutterBinding.ensureInitialized();

    //   final editor = tester.editor
    //     ..insertTextNode('0123456789')
    //     ..insertTextNode('0123456789')
    //     ..insertTextNode('0123456789');
    //   await editor.startTesting();
    //   await tester.pumpAndSettle();

    //   expect(editor.documentLength, 3);

    //   final selection = Selection(
    //     start: Position(path: [0], offset: 4),
    //     end: Position(path: [2], offset: 4),
    //   );
    //   final transaction = editor.editorState.transaction;
    //   var textNodes = [0, 1, 2]
    //       .map((e) => editor.nodeAtPath([e])!)
    //       .whereType<TextNode>()
    //       .toList(growable: false);
    //   final texts = ['ABC', 'ABC', 'ABC', 'ABC'];
    //   transaction.replaceTexts(textNodes, selection, texts);
    //   editor.editorState.apply(transaction);
    //   await tester.pumpAndSettle();

    //   expect(editor.documentLength, 4);
    //   textNodes = [0, 1, 2, 3]
    //       .map((e) => editor.nodeAtPath([e])!)
    //       .whereType<TextNode>()
    //       .toList(growable: false);
    //   expect(textNodes[0].toPlainText(), '0123ABC');
    //   expect(textNodes[1].toPlainText(), 'ABC');
    //   expect(textNodes[2].toPlainText(), 'ABC');
    //   expect(textNodes[3].toPlainText(), 'ABC456789');
    // });

    // testWidgets('test replaceTexts, textNodes.length << texts.length',
    //     (tester) async {
    //   TestWidgetsFlutterBinding.ensureInitialized();

    //   final editor = tester.editor..insertTextNode('Welcome to AppFlowy!');
    //   await editor.startTesting();
    //   await tester.pumpAndSettle();

    //   expect(editor.documentLength, 1);

    //   // select 'to'
    //   final selection = Selection(
    //     start: Position(path: [0], offset: 8),
    //     end: Position(path: [0], offset: 10),
    //   );
    //   final transaction = editor.editorState.transaction;
    //   var textNodes = [0]
    //       .map((e) => editor.nodeAtPath([e])!)
    //       .whereType<TextNode>()
    //       .toList(growable: false);
    //   final texts = ['ABC1', 'ABC2', 'ABC3', 'ABC4', 'ABC5'];
    //   transaction.replaceTexts(textNodes, selection, texts);
    //   editor.editorState.apply(transaction);
    //   await tester.pumpAndSettle();

    //   expect(editor.documentLength, 5);
    //   textNodes = [0, 1, 2, 3, 4]
    //       .map((e) => editor.nodeAtPath([e])!)
    //       .whereType<TextNode>()
    //       .toList(growable: false);
    //   expect(textNodes[0].toPlainText(), 'Welcome ABC1');
    //   expect(textNodes[1].toPlainText(), 'ABC2');
    //   expect(textNodes[2].toPlainText(), 'ABC3');
    //   expect(textNodes[3].toPlainText(), 'ABC4');
    //   expect(textNodes[4].toPlainText(), 'ABC5 AppFlowy!');
    // });

    // testWidgets('test selection propagates if non-selected node is deleted',
    //     (tester) async {
    //   TestWidgetsFlutterBinding.ensureInitialized();

    //   final editor = tester.editor
    //     ..insertTextNode('Welcome to AppFlowy!')
    //     ..insertTextNode('Testing selection on this');

    //   await editor.startTesting();
    //   await tester.pumpAndSettle();

    //   expect(editor.documentLength, 2);

    //   await editor.updateSelection(
    //     Selection.single(
    //       path: [0],
    //       startOffset: 0,
    //       endOffset: 20,
    //     ),
    //   );
    //   await tester.pumpAndSettle();

    //   final transaction = editor.editorState.transaction;
    //   transaction.deleteNode(editor.nodeAtPath([1])!);
    //   editor.editorState.apply(transaction);
    //   await tester.pumpAndSettle();

    //   expect(editor.documentLength, 1);
    //   expect(
    //     editor.editorState.cursorSelection,
    //     Selection.single(
    //       path: [0],
    //       startOffset: 0,
    //       endOffset: 20,
    //     ),
    //   );
    // });

    // testWidgets('test selection does not propagate if selected node is deleted',
    //     (tester) async {
    //   TestWidgetsFlutterBinding.ensureInitialized();

    //   final editor = tester.editor
    //     ..insertTextNode('Welcome to AppFlowy!')
    //     ..insertTextNode('Testing selection on this');

    //   await editor.startTesting();
    //   await tester.pumpAndSettle();

    //   expect(editor.documentLength, 2);

    //   await editor.updateSelection(
    //     Selection.single(
    //       path: [0],
    //       startOffset: 0,
    //       endOffset: 20,
    //     ),
    //   );
    //   await tester.pumpAndSettle();

    //   final transaction = editor.editorState.transaction;
    //   transaction.deleteNode(editor.nodeAtPath([0])!);
    //   editor.editorState.apply(transaction);
    //   await tester.pumpAndSettle();

    //   expect(editor.documentLength, 1);
    //   expect(editor.editorState.cursorSelection, null);
    // });
  });
}
