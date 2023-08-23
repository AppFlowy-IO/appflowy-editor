import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util/util.dart';

void main() async {
  group('allSatisfyInSelection - node', () {
    const welcome = 'Welcome ';
    const toAppFlowy = 'to AppFlowy';
    const editor = ' Editor 🔥!';

    // Welcome <b>|to AppFlowy</b> Editor 🔥!
    test('the selection is collapsed', () async {
      final document = Document.blank().addParagraph(
        builder: (index) => Delta()
          ..insert(welcome)
          ..insert(
            toAppFlowy,
            attributes: {
              'bold': true,
            },
          )
          ..insert(editor),
      );
      final editorState = EditorState(document: document);

      // Welcome |to AppFlowy| Editor 🔥!
      final selection = Selection.collapsed(
        Position(path: [0], offset: welcome.length),
      );
      editorState.selection = selection;
      final node = editorState.getNodeAtPath([0]);
      final result = node!.allSatisfyInSelection(selection, (delta) {
        final textInserts = delta.whereType<TextInsert>();
        return textInserts
            .every((element) => element.attributes?['bold'] == true);
      });
      expect(result, false);
    });

    // Welcome |<b>to AppFlowy</b>| Editor 🔥!
    test('the selection is single and not collapsed - 1', () async {
      final document = Document.blank().addParagraph(
        builder: (index) => Delta()
          ..insert(welcome)
          ..insert(
            toAppFlowy,
            attributes: {
              'bold': true,
            },
          )
          ..insert(editor),
      );
      final editorState = EditorState(document: document);

      // Welcome |to AppFlowy| Editor 🔥!
      final selection = Selection.single(
        path: [0],
        startOffset: welcome.length,
        endOffset: welcome.length + toAppFlowy.length,
      );
      editorState.selection = selection;
      final node = editorState.getNodeAtPath([0]);
      final result = node!.allSatisfyInSelection(selection, (delta) {
        final textInserts = delta.whereType<TextInsert>();
        return textInserts
            .every((element) => element.attributes?['bold'] == true);
      });

      expect(result, true);
    });

    // |Welcome <b>to AppFlowy</b>| Editor 🔥!
    test('the selection is single and not collapsed - 2', () async {
      final document = Document.blank().addParagraph(
        builder: (index) => Delta()
          ..insert(welcome)
          ..insert(
            toAppFlowy,
            attributes: {
              'bold': true,
            },
          )
          ..insert(editor),
      );
      final editorState = EditorState(document: document);

      // Welcome |to AppFlowy| Editor 🔥!
      final selection = Selection.single(
        path: [0],
        startOffset: 0,
        endOffset: welcome.length + toAppFlowy.length,
      );
      editorState.selection = selection;
      final node = editorState.getNodeAtPath([0]);
      final result = node!.allSatisfyInSelection(selection, (delta) {
        final textInserts = delta.whereType<TextInsert>();
        return textInserts
            .every((element) => element.attributes?['bold'] == true);
      });
      expect(result, false);
    });
  });

  group('allSatisfyInSelection - nodes', () {
    const welcome = 'Welcome ';
    const toAppFlowy = 'to AppFlowy';
    const editor = ' Editor 🔥!';

    // Welcome <b>|to AppFlowy Editor 🔥!</b>
    // <b>Welcome to AppFlowy|</b> Editor 🔥!
    test('the selection is not collapsed and not single - 1', () async {
      final document = Document.blank().addParagraph(
        builder: (index) => Delta()
          ..insert(welcome)
          ..insert(
            toAppFlowy + editor,
            attributes: {
              'bold': true,
            },
          ),
      )..addParagraph(
          builder: (index) => Delta()
            ..insert(
              welcome + toAppFlowy,
              attributes: {
                'bold': true,
              },
            )
            ..insert(
              editor,
            ),
        );
      final editorState = EditorState(document: document);

      // Welcome <b>|to AppFlowy Editor 🔥!</b>
      // <b>Welcome to AppFlowy|</b> Editor 🔥!
      final selection = Selection(
        start: Position(path: [0], offset: welcome.length),
        end: Position(path: [1], offset: welcome.length + toAppFlowy.length),
      );
      editorState.selection = selection;
      final nodes = editorState.getNodesInSelection(selection);
      final result = nodes.allSatisfyInSelection(selection, (delta) {
        final textInserts = delta.whereType<TextInsert>();
        return textInserts
            .every((element) => element.attributes?['bold'] == true);
      });
      expect(result, true);
    });

    // |Welcome <b>to AppFlowy Editor 🔥!</b>
    // <b>Welcome to AppFlowy</b> Editor 🔥!|
    test('the selection is not collapsed and not single - 2', () async {
      final document = Document.blank().addParagraph(
        builder: (index) => Delta()
          ..insert(welcome)
          ..insert(
            toAppFlowy + editor,
            attributes: {
              'bold': true,
            },
          ),
      )..addParagraph(
          builder: (index) => Delta()
            ..insert(
              welcome + toAppFlowy,
              attributes: {
                'bold': true,
              },
            )
            ..insert(
              editor,
            ),
        );
      final editorState = EditorState(document: document);

      // |Welcome <b>to AppFlowy Editor 🔥!</b>
      // <b>Welcome to AppFlowy</b> Editor 🔥!|
      final selection = Selection(
        start: Position(path: [0], offset: 0),
        end: Position(
          path: [1],
          offset: welcome.length + toAppFlowy.length + editor.length,
        ),
      );
      editorState.selection = selection;
      final nodes = editorState.getNodesInSelection(selection);
      final result = nodes.allSatisfyInSelection(selection, (delta) {
        final textInserts = delta.whereType<TextInsert>();
        return textInserts
            .every((element) => element.attributes?['bold'] == true);
      });
      expect(result, false);
    });
  });
}
