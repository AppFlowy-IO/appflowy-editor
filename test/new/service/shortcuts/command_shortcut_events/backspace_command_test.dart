import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../util/util.dart';

void main() async {
  group('backspace_command.dart', () {
    group('backspaceCommand', () {
      const text = 'Welcome to AppFlowy Editor 🔥!';
      // Before
      // Welcome| to AppFlowy Editor 🔥!
      // After
      // | to AppFlowy Editor 🔥!
      test('delete in collapsed selection when the index > 0', () async {
        final document = Document.blank().combineParagraphs(
          1,
          builder: (index) => Delta()..insert(text),
        );
        final editorState = EditorState(document: document);

        const index = 'Welcome'.length;
        // Welcome| to AppFlowy Editor 🔥!
        final selection = Selection.collapsed(
          Position(path: [0], offset: index),
        );
        editorState.selection = selection;
        for (var i = 0; i < index; i++) {
          final result = backspaceCommand.execute(editorState);
          expect(result, KeyEventResult.handled);
        }

        final after = editorState.getNodeAtPath([0])!;
        expect(after.delta!.toPlainText(), text.substring(index));
      });

      // Before
      // |Welcome to AppFlowy Editor 🔥!
      // After
      // |Welcome to AppFlowy Editor 🔥!
      test(
          'Delete the collapsed selection when the index is 0 and there is no previous node that contains a delta',
          () async {
        final document = Document.blank().combineParagraphs(
          1,
          builder: (index) => Delta()..insert(text),
        );
        final editorState = EditorState(document: document);

        // |Welcome to AppFlowy Editor 🔥!
        final selection = Selection.collapsed(
          Position(path: [0], offset: 0),
        );
        editorState.selection = selection;

        final result = backspaceCommand.execute(editorState);
        expect(result, KeyEventResult.ignored);

        final after = editorState.getNodeAtPath([0])!;
        expect(after.delta!.toPlainText(), text);
        expect(editorState.selection, selection);
      });

      // Before
      // Welcome to AppFlowy Editor 🔥!
      // |Welcome to AppFlowy Editor 🔥!
      // After
      // Welcome to AppFlowy Editor 🔥!|Welcome to AppFlowy Editor 🔥!
      test('''Delete the collapsed selection when the index is 0
          and there is a previous node that contains a delta
          and the previous node is in the same level with the current node''',
          () async {
        final document = Document.blank().combineParagraphs(
          2,
          builder: (index) => Delta()..insert(text),
        );
        final editorState = EditorState(document: document);

        // Welcome to AppFlowy Editor 🔥!
        // |Welcome to AppFlowy Editor 🔥!
        final selection = Selection.collapsed(
          Position(path: [1], offset: 0),
        );
        editorState.selection = selection;

        final result = backspaceCommand.execute(editorState);
        expect(result, KeyEventResult.handled);

        // the second node should be deleted.
        expect(editorState.getNodeAtPath([1]), null);

        // the first node should be combined with the second node.
        final after = editorState.getNodeAtPath([0])!;
        expect(after.delta!.toPlainText(), text * 2);
        expect(
          editorState.selection,
          Selection.collapsed(
            Position(path: [0], offset: text.length),
          ),
        );
      });

      // Before
      // Welcome to AppFlowy Editor 🔥!
      //    |Welcome to AppFlowy Editor 🔥!
      // After
      // Welcome to AppFlowy Editor 🔥!
      // |Welcome to AppFlowy Editor 🔥!
      test('''Delete the collapsed selection when the index is 0
          and there is a previous node that contains a delta
          and the previous node is the parent of the current node''', () async {
        final document = Document.blank().combineParagraphs(
          1,
          builder: (index) => Delta()..insert(text),
          decorator: (index, node) => node.appendParagraphs(
            1,
            builder: (index) => Delta()..insert(text),
          ),
        );
        final editorState = EditorState(document: document);

        // Welcome to AppFlowy Editor 🔥!
        // |Welcome to AppFlowy Editor 🔥!
        final selection = Selection.collapsed(
          Position(path: [0, 0], offset: 0),
        );
        editorState.selection = selection;

        final result = backspaceCommand.execute(editorState);
        expect(result, KeyEventResult.handled);

        // the second node should be moved to the same level as it's parent.
        expect(editorState.getNodeAtPath([0, 1]), null);
        final after = editorState.getNodeAtPath([1])!;
        expect(after.delta!.toPlainText(), text);
        expect(
          editorState.selection,
          Selection.collapsed(
            Position(path: [1], offset: 0),
          ),
        );
      });
    });
  });
}
