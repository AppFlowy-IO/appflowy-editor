import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util/util.dart';

void main() async {
  group('deleteSelection', () {
    test('the selection is collapsed', () async {
      final document = Document.blank().addParagraphs(
        3,
        builder: (index) =>
            Delta()..insert('$index. Welcome to AppFlowy Editor 🔥!'),
      );
      final editorState = EditorState(document: document);

      final selection = Selection.collapsed(
        Position(path: [1], offset: 10),
      );
      final before = editorState.getNodesInSelection(selection).first;
      final result = await editorState.deleteSelection(selection);

      // nothing happens
      expect(result, false);
      final after = editorState.getNodesInSelection(selection).first;
      expect(
        before.toJson(),
        after.toJson(),
      );
    });

    test('the selection is single', () async {
      final document = Document.blank().addParagraphs(
        3,
        builder: (index) =>
            Delta()..insert('$index. Welcome to AppFlowy Editor 🔥!'),
      );
      final editorState = EditorState(document: document);

      // |Welcome|
      final selection = Selection.single(
        path: [1],
        startOffset: 3,
        endOffset: 10,
      );
      final result = await editorState.deleteSelection(selection);

      // nothing happens
      expect(result, true);
      expect(editorState.selection, selection.collapse(atStart: true));
      final after = editorState.getNodesInSelection(selection).first;
      expect(after.delta?.toPlainText(), '1.  to AppFlowy Editor 🔥!');
    });

    test('the selection is not single and not collapsed - 1', () async {
      final document = Document.blank().addParagraphs(
        3,
        builder: (index) =>
            Delta()..insert('$index. Welcome to AppFlowy Editor 🔥!'),
      );
      final editorState = EditorState(document: document);

      // |Welcome
      // ...
      // Welcome|
      final selection = Selection(
        start: Position(
          path: [0],
          offset: 3,
        ),
        end: Position(
          path: [2],
          offset: 10,
        ),
      );
      final result = await editorState.deleteSelection(selection);

      // nothing happens
      expect(result, true);
      expect(editorState.selection, selection.collapse(atStart: true));
      final length = editorState.document.root.children.length;
      expect(length, 1);
      expect(
        editorState.document.nodeAtPath([0])?.delta?.toPlainText(),
        '0.  to AppFlowy Editor 🔥!',
      );
    });

    // Before
    // 0. Welcome |to AppFlowy Editor 🔥!
    //   0.0. Welcome |to AppFlowy Editor 🔥!
    //     0.0.0. Welcome to AppFlowy Editor 🔥!
    //   0.1. Welcome to AppFlowy Editor 🔥!
    // After
    // 0. Welcome to AppFlowy Editor 🔥!
    //   0.0.0. Welcome to AppFlowy Editor 🔥!
    //   0.1. Welcome to AppFlowy Editor 🔥!
    test('the selection is not single and not collapsed - 2', () async {
      final document = Document.blank().addParagraph(
        builder: (index) =>
            Delta()..insert('$index. Welcome to AppFlowy Editor 🔥!'),
        decorator: (index, node) {
          node.addParagraphs(
            2,
            builder: (index2) => Delta()
              ..insert('$index.$index2. Welcome to AppFlowy Editor 🔥!'),
            decorator: (index2, node2) {
              if (index2 == 0) {
                node2.addParagraph(
                  builder: (index3) => Delta()
                    ..insert(
                      '$index.$index2.$index3. Welcome to AppFlowy Editor 🔥!',
                    ),
                );
              }
            },
          );
        },
      );
      final editorState = EditorState(document: document);

      // 0. Welcome |to AppFlowy Editor 🔥!
      //   0.0. Welcome |to AppFlowy Editor 🔥!
      //     0.0.0 Welcome to AppFlowy Editor 🔥!
      //   0.1 Welcome to AppFlowy Editor 🔥!
      final selection = Selection(
        start: Position(
          path: [0],
          offset: '0. Welcome '.length,
        ),
        end: Position(
          path: [0, 0],
          offset: '0.0. Welcome '.length,
        ),
      );
      final result = await editorState.deleteSelection(selection);

      // nothing happens
      expect(result, true);
      expect(editorState.selection, selection.collapse(atStart: true));
      expect(
        editorState.document.nodeAtPath([0])?.delta?.toPlainText(),
        '0. Welcome to AppFlowy Editor 🔥!',
      );
      expect(
        editorState.document.nodeAtPath([0, 0])?.delta?.toPlainText(),
        '0.0.0. Welcome to AppFlowy Editor 🔥!',
      );
      expect(
        editorState.document.nodeAtPath([0, 1])?.delta?.toPlainText(),
        '0.1. Welcome to AppFlowy Editor 🔥!',
      );
    });
  });
}
