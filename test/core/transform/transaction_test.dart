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

    const replaceText1 = 'Click to start typing.';
    const replaceText2 = 'Highlight text to style it using the editing menu.';
    const replaceText3 =
        'Type / to access a menu for adding different content blocks.';

    const text1 = 'Click anywhere and just start typing';
    const text2 =
        'Highlight any text, and use the editing menu to style your writing however you like.';
    const text3 =
        'As soon as you type / a menu will pop up. Select different types of content blocks you can add.';

    test('replace texts, nodes.length > texts.length', () async {
      final document = Document(
        root: pageNode(
          children: [
            todoListNode(checked: false, text: text1),
            todoListNode(checked: false, text: text2),
            todoListNode(checked: false, text: text3),
          ],
        ),
      );
      final editorState = EditorState(document: document);
      final selection = Selection(
        start: Position(path: [0], offset: 0),
        end: Position(path: [2], offset: text3.length),
      );
      editorState.selection = selection;
      final transaction = editorState.transaction;
      final nodes = editorState.getNodesInSelection(selection);
      transaction.replaceTexts(nodes, selection, [replaceText1]);
      await editorState.apply(transaction);
      expect(editorState.document.root.children.length, 1);
      expect(
        editorState.getNodeAtPath([0])?.delta?.toPlainText(),
        replaceText1,
      );
    });

    test('replace texts, nodes.length < texts.length', () async {
      final document = Document(
        root: pageNode(
          children: [
            todoListNode(checked: false, text: text1),
          ],
        ),
      );
      final editorState = EditorState(document: document);
      final selection = Selection(
        start: Position(path: [0], offset: 0),
        end: Position(path: [0], offset: text1.length),
      );
      editorState.selection = selection;
      final transaction = editorState.transaction;
      final nodes = editorState.getNodesInSelection(selection);
      transaction.replaceTexts(
        nodes,
        selection,
        [replaceText1, replaceText2, replaceText3],
      );
      await editorState.apply(transaction);
      expect(editorState.document.root.children.length, 3);
      expect(
        editorState.getNodeAtPath([0])?.delta?.toPlainText(),
        replaceText1,
      );
      expect(
        editorState.getNodeAtPath([1])?.delta?.toPlainText(),
        replaceText2,
      );
      expect(
        editorState.getNodeAtPath([2])?.delta?.toPlainText(),
        replaceText3,
      );
    });

    test('replace texts, nodes.length == texts.length', () async {
      final document = Document(
        root: pageNode(
          children: [
            todoListNode(checked: false, text: text1),
            todoListNode(checked: false, text: text2),
            todoListNode(checked: false, text: text3),
          ],
        ),
      );
      final editorState = EditorState(document: document);
      final selection = Selection(
        start: Position(path: [0], offset: 0),
        end: Position(path: [2], offset: text3.length),
      );
      editorState.selection = selection;
      final transaction = editorState.transaction;
      final nodes = editorState.getNodesInSelection(selection);
      transaction.replaceTexts(
        nodes,
        selection,
        [replaceText1, replaceText2, replaceText3],
      );
      await editorState.apply(transaction);
      expect(editorState.document.root.children.length, 3);
      expect(
        editorState.getNodeAtPath([0])?.delta?.toPlainText(),
        replaceText1,
      );
      expect(
        editorState.getNodeAtPath([1])?.delta?.toPlainText(),
        replaceText2,
      );
      expect(
        editorState.getNodeAtPath([2])?.delta?.toPlainText(),
        replaceText3,
      );
    });

    test('test replace texts, attributes', () async {
      final document = Document(
        root: pageNode(
          children: [
            paragraphNode(
              delta: Delta()
                ..insert('Hello', attributes: {'href': 'appflowy.io'}),
            ),
          ],
        ),
      );
      final editorState = EditorState(document: document);
      final selection = Selection(
        start: Position(path: [0], offset: 0),
        end: Position(path: [0], offset: 5),
      );
      editorState.selection = selection;
      final transaction = editorState.transaction;
      final node = editorState.getNodeAtPath([0])!;
      transaction.replaceText(node, 0, 5, 'AppFlowy');
      await editorState.apply(transaction);
      expect(editorState.document.root.children.length, 1);
      final delta = editorState.getNodeAtPath([0])?.delta;
      expect(delta?.toJson(), [
        {
          'insert': 'AppFlowy',
          'attributes': {'href': 'appflowy.io'},
        }
      ]);
    });
  });

  test('test replace texts, after selection - 1', () async {
    final document = Document(
      root: pageNode(
        children: [
          bulletedListNode(
            text: 'bulleted item 1',
            children: [
              paragraphNode(text: 'paragraph 1-1'),
              paragraphNode(text: 'paragraph 1-2'),
              paragraphNode(text: 'paragraph 1-3'),
            ],
          ),
          bulletedListNode(
            text: 'bulleted item 2',
            children: [
              paragraphNode(text: 'paragraph 2-1'),
              paragraphNode(text: 'paragraph 2-2'),
              paragraphNode(text: 'paragraph 2-3'),
            ],
          ),
          bulletedListNode(
            text: 'bulleted item 3',
            children: [
              paragraphNode(text: 'paragraph 3-1'),
              paragraphNode(text: 'paragraph 3-2'),
              paragraphNode(text: 'paragraph 3-3'),
            ],
          ),
        ],
      ),
    );
    final editorState = EditorState(document: document);
    final selection = Selection(
      start: Position(path: [0, 0], offset: 0),
      end: Position(path: [0, 2], offset: 'paragraph 1-3'.length),
    );
    editorState.selection = selection;
    final transaction = editorState.transaction;
    final nodes = editorState.getNodesInSelection(selection);
    transaction.replaceTexts(
      nodes,
      selection,
      ['replaced 1-1', 'replaced 1-2', 'replaced 1-3'],
    );
    await editorState.apply(transaction);
    expect(editorState.document.root.children.length, 3);
    expect(
      editorState.getNodeAtPath([0, 0])?.delta?.toPlainText(),
      'replaced 1-1',
    );
    expect(
      editorState.getNodeAtPath([0, 1])?.delta?.toPlainText(),
      'replaced 1-2',
    );
    expect(
      editorState.getNodeAtPath([0, 2])?.delta?.toPlainText(),
      'replaced 1-3',
    );
    expect(
      editorState.selection,
      selection.copyWith(
        end: Position(path: [0, 2], offset: 'replaced 1-3'.length),
      ),
    );
  });

  test('test replace texts, after selection - 2', () async {
    final document = Document(
      root: pageNode(
        children: [
          bulletedListNode(
            text: 'bulleted item 1',
            children: [
              paragraphNode(text: 'paragraph 1-1'),
              paragraphNode(text: 'paragraph 1-2'),
              paragraphNode(text: 'paragraph 1-3'),
              paragraphNode(text: 'paragraph 1-4'),
            ],
          ),
          bulletedListNode(
            text: 'bulleted item 2',
            children: [
              paragraphNode(text: 'paragraph 2-1'),
              paragraphNode(text: 'paragraph 2-2'),
              paragraphNode(text: 'paragraph 2-3'),
            ],
          ),
          bulletedListNode(
            text: 'bulleted item 3',
            children: [
              paragraphNode(text: 'paragraph 3-1'),
              paragraphNode(text: 'paragraph 3-2'),
              paragraphNode(text: 'paragraph 3-3'),
            ],
          ),
        ],
      ),
    );
    final editorState = EditorState(document: document);
    final selection = Selection(
      start: Position(path: [0, 0], offset: 0),
      end: Position(path: [0, 3], offset: 'paragraph 1-4'.length),
    );
    editorState.selection = selection;
    final transaction = editorState.transaction;
    final nodes = editorState.getNodesInSelection(selection);
    transaction.replaceTexts(
      nodes,
      selection,
      ['replaced 1-1', 'replaced 1-2', 'replaced 1-3'],
    );
    await editorState.apply(transaction);
    expect(editorState.getNodeAtPath([0])!.children.length, 3);
    expect(
      editorState.selection,
      selection.copyWith(
        end: Position(path: [0, 2], offset: 'replaced 1-3'.length),
      ),
    );
  });

  test('test replace texts, after selection - 3', () async {
    final document = Document(
      root: pageNode(
        children: [
          bulletedListNode(
            text: 'bulleted item 1',
            children: [
              paragraphNode(text: 'paragraph 1-1'),
              paragraphNode(text: 'paragraph 1-2'),
              paragraphNode(text: 'paragraph 1-3'),
            ],
          ),
          bulletedListNode(
            text: 'bulleted item 2',
            children: [
              paragraphNode(text: 'paragraph 2-1'),
              paragraphNode(text: 'paragraph 2-2'),
              paragraphNode(text: 'paragraph 2-3'),
            ],
          ),
          bulletedListNode(
            text: 'bulleted item 3',
            children: [
              paragraphNode(text: 'paragraph 3-1'),
              paragraphNode(text: 'paragraph 3-2'),
              paragraphNode(text: 'paragraph 3-3'),
            ],
          ),
        ],
      ),
    );
    final editorState = EditorState(document: document);
    final selection = Selection(
      start: Position(path: [0, 0], offset: 0),
      end: Position(path: [0, 2], offset: 'paragraph 1-3'.length),
    );
    editorState.selection = selection;
    final transaction = editorState.transaction;
    final nodes = editorState.getNodesInSelection(selection);
    transaction.replaceTexts(
      nodes,
      selection,
      [
        'replaced 1-1',
        'replaced 1-2',
        'replaced 1-3',
        'replaced 1-4',
        'replaced 1-5',
      ],
    );
    await editorState.apply(transaction);
    expect(editorState.getNodeAtPath([0])!.children.length, 5);
    expect(
      editorState.selection,
      selection.copyWith(
        end: Position(path: [0, 4], offset: 'replaced 1-5'.length),
      ),
    );
  });
}
