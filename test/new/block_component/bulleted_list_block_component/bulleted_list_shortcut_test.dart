import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../util/document_util.dart';

void main() async {
  group('bulleted_list_shortcut.dart', () {
    group('formatAsteriskToBulletedList', () {
      // Before
      // *|Welcome to AppFlowy Editor 🔥!
      // After
      // [bulleted_list]Welcome to AppFlowy Editor 🔥!
      test(
          'mock inputting a ` ` after asterisk which is located at the front of the text',
          () async {
        const text = 'Welcome to AppFlowy Editor 🔥!';
        final document = Document.blank().combineParagraphs(
          1,
          builder: (index) => Delta()..insert('*$text'),
        );
        final editorState = EditorState(document: document);

        // *|Welcome to AppFlowy Editor 🔥!
        final selection = Selection.collapsed(
          Position(path: [0], offset: 1),
        );
        editorState.selection = selection;
        final result = await formatAsteriskToBulletedList.execute(editorState);

        expect(result, true);
        final after = editorState.getNodeAtPath([0])!;
        expect(after.delta!.toPlainText(), text);
        expect(after.type, 'bulleted_list');
      });

      // Before
      // *W|elcome to AppFlowy Editor 🔥!
      // After
      // *W|elcome to AppFlowy Editor 🔥!
      test('mock inputting a ` ` in the middle of the text', () async {
        const text = 'Welcome to AppFlowy Editor 🔥!';
        final document = Document.blank().combineParagraphs(
          1,
          builder: (index) => Delta()..insert('*$text'),
        );
        final editorState = EditorState(document: document);

        // *W|elcome to AppFlowy Editor 🔥!
        final selection = Selection.collapsed(
          Position(path: [0], offset: 2),
        );
        editorState.selection = selection;
        final before = editorState.getNodesInSelection(selection).first;
        final result = await formatAsteriskToBulletedList.execute(editorState);
        final after = editorState.getNodesInSelection(selection).first;

        // nothing happens
        expect(result, false);
        expect(before.toJson(), after.toJson());
      });
    });
  });
}
