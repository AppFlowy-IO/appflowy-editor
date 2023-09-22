import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../new/util/util.dart';

void main() async {
  group('transaction.dart', () {
    test('set operations', () {
      final document = Document.blank().addParagraphs(
        4,
        initialText: 'example',
      );

      final transaction = Transaction(document: document);

      expect(transaction.operations.length, 0);

      final node = Node(type: 'paragraph');
      transaction.add(InsertOperation([0], [node]));

      expect(transaction.operations.length, 1);

      transaction.operations = [];
      expect(transaction.operations.length, 0);
    });

    test('deleteNodes', () async {
      final n1 = Node(type: 'paragraph-1');
      final n2 = Node(type: 'paragraph-2');
      final n3 = Node(type: 'paragraph-3');
      final document = Document.blank()..insert([0], [n1, n2, n3]);

      final editorState = EditorState(document: document);

      expect(document.first!.type, 'paragraph-1');
      expect(document.last!.type, 'paragraph-3');
      expect(editorState.document.root.children.length, 3);

      final transaction = editorState.transaction;
      transaction.deleteNodes([n1, n3]);
      await editorState.apply(transaction);

      expect(editorState.document.root.children.length, 1);
      expect(editorState.document.first!.type, 'paragraph-2');
    });

    test('moveNode', () async {
      final n1 = Node(type: 'paragraph-1');
      final n2 = Node(type: 'paragraph-2');
      final n3 = Node(type: 'paragraph-3');
      final document = Document.blank()..insert([0], [n1, n2, n3]);

      final editorState = EditorState(document: document);

      expect(document.first!.type, 'paragraph-1');
      expect(document.last!.type, 'paragraph-3');
      expect(editorState.document.root.children.length, 3);

      final transaction = editorState.transaction;
      transaction.moveNode([0], n3);
      await editorState.apply(transaction);

      expect(editorState.document.first!.type, 'paragraph-3');
      expect(editorState.document.last!.type, 'paragraph-2');
    });

    test('toJson', () {
      final beforeSelection = Selection.collapsed(Position(path: [0]));
      final afterSelection =
          Selection.collapsed(Position(path: [0], offset: 'paragraph'.length));
      final io = InsertOperation([0], [Node(type: 'paragraph')]);

      final empty = {};

      final withOperation = {
        "operations": [
          io.toJson(),
        ],
      };

      final withAfterSelection = {
        ...withOperation,
        "after_selection": afterSelection.toJson(),
      };

      final withBeforeSelection = {
        ...withAfterSelection,
        "before_selection": beforeSelection.toJson(),
      };

      final transaction = Transaction(document: Document.blank());
      expect(transaction.toJson(), empty);

      transaction.add(io);
      expect(transaction.toJson(), withOperation);

      transaction.afterSelection = afterSelection;
      expect(transaction.toJson(), withAfterSelection);

      transaction.beforeSelection = beforeSelection;
      expect(transaction.toJson(), withBeforeSelection);
    });

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

      nodes = editorState.getNodesInSelection(selection);

      expect(editorState.document.root.children.length, 4);
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

    test('test replaceTexts, textNodes.length < texts.length', () async {
      final document = Document.blank().addParagraphs(
        3,
        initialText: '0123456789',
      );
      final editorState = EditorState(document: document);

      expect(editorState.document.root.children.length, 3);

      final selection = Selection(
        start: Position(path: [0], offset: 4),
        end: Position(path: [2], offset: 4),
      );
      final transaction = editorState.transaction;
      final nodes = editorState.getNodesInSelection(selection);

      final texts = ['ABC', 'ABC', 'ABC', 'ABC'];
      transaction.replaceTexts(nodes, selection, texts);
      await editorState.apply(transaction);

      expect(editorState.document.root.children.length, 4);
      expect(editorState.getNodeAtPath([0])?.delta?.toPlainText(), '0123ABC');
      expect(editorState.getNodeAtPath([1])?.delta?.toPlainText(), 'ABC');
      expect(editorState.getNodeAtPath([2])?.delta?.toPlainText(), 'ABC');
      expect(editorState.getNodeAtPath([3])?.delta?.toPlainText(), 'ABC456789');
    });

    test('test replaceTexts, textNodes.length << texts.length', () async {
      final document = Document.blank().addParagraphs(
        1,
        initialText: 'Welcome to AppFlowy!',
      );
      final editorState = EditorState(document: document);

      expect(editorState.document.root.children.length, 1);

      // select 'to'
      final selection = Selection(
        start: Position(path: [0], offset: 8),
        end: Position(path: [0], offset: 10),
      );
      final transaction = editorState.transaction;
      var nodes = editorState.getNodesInSelection(selection);
      final texts = ['ABC1', 'ABC2', 'ABC3', 'ABC4', 'ABC5'];
      transaction.replaceTexts(nodes, selection, texts);
      await editorState.apply(transaction);

      expect(editorState.document.root.children.length, 5);
      expect(
        editorState.getNodeAtPath([0])?.delta?.toPlainText(),
        'Welcome ABC1',
      );
      expect(editorState.getNodeAtPath([1])?.delta?.toPlainText(), 'ABC2');
      expect(editorState.getNodeAtPath([2])?.delta?.toPlainText(), 'ABC3');
      expect(editorState.getNodeAtPath([3])?.delta?.toPlainText(), 'ABC4');
      expect(
        editorState.getNodeAtPath([4])?.delta?.toPlainText(),
        'ABC5 AppFlowy!',
      );
    });

    test('test selection propagates if non-selected node is deleted', () async {
      final document = Document.blank()
          .addParagraphs(
            1,
            initialText: 'Welcome to AppFlowy!',
          )
          .addParagraphs(
            1,
            initialText: 'Testing selection on this',
          );
      final editorState = EditorState(document: document);

      expect(editorState.document.root.children.length, 2);

      editorState.selection = Selection.single(
        path: [0],
        startOffset: 0,
        endOffset: 20,
      );

      final transaction = editorState.transaction;
      transaction.deleteNode(editorState.getNodeAtPath([1])!);
      await editorState.apply(transaction);

      expect(editorState.document.root.children.length, 1);
      expect(
        editorState.selection,
        Selection.single(
          path: [0],
          startOffset: 0,
          endOffset: 20,
        ),
      );
    });

    test('test selection does not propagate if selected node is deleted',
        () async {
      final document = Document.blank()
          .addParagraphs(
            1,
            initialText: 'Welcome to AppFlowy!',
          )
          .addParagraphs(
            1,
            initialText: 'Testing selection on this',
          );
      final editorState = EditorState(document: document);

      expect(editorState.document.root.children.length, 2);

      editorState.selection = Selection.single(
        path: [0],
        startOffset: 0,
        endOffset: 20,
      );

      final transaction = editorState.transaction;
      transaction.deleteNode(editorState.getNodeAtPath([0])!);
      await editorState.apply(transaction);

      expect(editorState.document.root.children.length, 1);
      expect(
        editorState.selection,
        null,
      );
    });
  });
}
