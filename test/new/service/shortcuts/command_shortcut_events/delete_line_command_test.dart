import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../util/util.dart';

void main() async {
  group('deleteLineCommand', () {
    group('delete current line if the selection is collapsed', () {
      const text = 'Welcome to AppFlowy Editor 🔥!';

      test('delete in collapsed selection when the index > 0', () async {
        final document = Document.blank().addParagraphs(
          2,
          builder: (index) => Delta()..insert('${index + 1}. $text'),
        );
        final editorState = EditorState(document: document);

        final selection = Selection.collapsed(
          Position(path: [0], offset: text.length),
        );
        editorState.selection = selection;

        final result = deleteLineCommand.execute(editorState);
        expect(result, KeyEventResult.handled);

        final after = editorState.getNodeAtPath([0])!;
        expect(after.delta!.toPlainText(), '2. $text');
      });

      test('do nothing if the selection is not collapsed', () async {
        final document = Document.blank().addParagraphs(
          2,
          builder: (index) => Delta()..insert('${index + 1}. $text'),
        );
        final editorState = EditorState(document: document);

        final selection = Selection(
          start: Position(path: [0], offset: 0),
          end: Position(path: [0], offset: text.length),
        );
        editorState.selection = selection;

        final result = deleteLineCommand.execute(editorState);
        expect(result, KeyEventResult.ignored);

        expect(
          editorState.getNodeAtPath([0])!.delta!.toPlainText(),
          '1. $text',
        );
        expect(
          editorState.getNodeAtPath([1])!.delta!.toPlainText(),
          '2. $text',
        );
        expect(editorState.selection, selection);
      });
    });
  });
}
