import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../util/util.dart';

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

  group('formatAsteriskToBulletedList', () {
    // Before
    // *|Welcome to AppFlowy Editor 🔥!
    // After
    // [bulleted_list]Welcome to AppFlowy Editor 🔥!
    test(
        'mock inputting a ` ` after asterisk which is located at the front of the text',
        () async {
      const text = 'Welcome to AppFlowy Editor 🔥!';
      final document = Document.blank().addParagraphs(
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
      final document = Document.blank().addParagraphs(
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

    // Before
    // Welcome to AppFlowy Editor 🔥!
    // *|Welcome to AppFlowy Editor 🔥!
    // After
    // Welcome to AppFlowy Editor 🔥!
    //[bulleted_list] Welcome to AppFlowy Editor 🔥!
    test('mock inputting a ` ` in the middle of the text', () async {
      const text = 'Welcome to AppFlowy Editor 🔥!';
      final document = Document.blank()
          .addParagraphs(
            1,
            builder: (index) => Delta()..insert(text),
          )
          .addParagraphs(
            1,
            builder: (index) => Delta()..insert('*$text'),
          );
      final editorState = EditorState(document: document);

      // Welcome to AppFlowy Editor 🔥!
      // *|Welcome to AppFlowy Editor 🔥!
      final selection = Selection.collapsed(
        Position(path: [1], offset: 1),
      );
      editorState.selection = selection;
      final result = await formatAsteriskToBulletedList.execute(editorState);
      final after = editorState.getNodeAtPath([1])!;

      // the second line will be formatted as the bulleted list style
      expect(result, true);
      expect(after.type, 'bulleted_list');
      expect(after.delta!.toPlainText(), text);
    });
  });
}
