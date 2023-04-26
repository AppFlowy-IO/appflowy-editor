import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util/util.dart';

void main() async {
  setUpAll(() {
    if (kDebugMode) {
      activateLog();
    }
  });

  tearDownAll(() {
    if (kDebugMode) {
      deactivateLog();
    }
  });

  group('selection_transform.dart', () {
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

      test('the selection is not single and not collapsed', () async {
        final document = Document.blank().addParagraphs(
          3,
          builder: (index) =>
              Delta()..insert('$index. Welcome to AppFlowy Editor 🔥!'),
        );
        final editorState = EditorState(document: document);

        // |Welcome
        // ...
        /// Welcome|
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
    });
  });
}
