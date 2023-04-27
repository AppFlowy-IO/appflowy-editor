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

  group('formatNumberToNumberedList', () {
    // Before
    // 1|Welcome to AppFlowy Editor 🔥!
    // After
    // 1|Welcome to AppFlowy Editor 🔥!
    test('mock inputting a ` ` after the number but not dot', () async {
      const text = 'Welcome to AppFlowy Editor 🔥!';
      final document = Document.blank().addParagraphs(
        1,
        builder: (index) => Delta()..insert('1$text'),
      );
      final editorState = EditorState(document: document);

      // 1|Welcome to AppFlowy Editor 🔥!
      final selection = Selection.collapsed(
        Position(path: [0], offset: 1),
      );
      editorState.selection = selection;
      final before = editorState.getNodesInSelection(selection).first;
      final result = await formatNumberToNumberedList.execute(editorState);
      final after = editorState.getNodesInSelection(selection).first;

      // nothing happens
      expect(result, false);
      expect(before.toJson(), after.toJson());
    });

    // Before
    // 1.|Welcome to AppFlowy Editor 🔥!
    // After
    // [numbered_list]Welcome to AppFlowy Editor 🔥!
    test(
        'mock inputting a ` ` after the number which is located at the front of the text',
        () async {
      const text = 'Welcome to AppFlowy Editor 🔥!';
      final document = Document.blank().addParagraphs(
        1,
        builder: (index) => Delta()..insert('1.$text'),
      );
      final editorState = EditorState(document: document);

      // 1.|Welcome to AppFlowy Editor 🔥!
      final selection = Selection.collapsed(
        Position(path: [0], offset: 2),
      );
      editorState.selection = selection;
      final result = await formatNumberToNumberedList.execute(editorState);

      expect(result, true);
      final after = editorState.getNodeAtPath([0])!;
      expect(after.delta!.toPlainText(), text);
      expect(after.type, 'numbered_list');
    });

    // Before
    // 1.W|elcome to AppFlowy Editor 🔥!
    // After
    // 1.W|elcome to AppFlowy Editor 🔥!
    test('mock inputting a ` ` in the middle of the node', () async {
      const text = 'Welcome to AppFlowy Editor 🔥!';
      final document = Document.blank().addParagraphs(
        1,
        builder: (index) => Delta()..insert('1.$text'),
      );
      final editorState = EditorState(document: document);

      // 1.W|elcome to AppFlowy Editor 🔥!
      final selection = Selection.collapsed(
        Position(path: [0], offset: 3),
      );
      editorState.selection = selection;
      final before = editorState.getNodesInSelection(selection).first;
      final result = await formatNumberToNumberedList.execute(editorState);
      final after = editorState.getNodesInSelection(selection).first;

      // nothing happens
      expect(result, false);
      expect(before.toJson(), after.toJson());
    });

    // Before
    // Welcome to AppFlowy Editor 🔥!
    // 1.|Welcome to AppFlowy Editor 🔥!
    // After
    // Welcome to AppFlowy Editor 🔥!
    //[numbered_list] Welcome to AppFlowy Editor 🔥!
    test(
        'mock inputting a ` ` in the middle of the node, and there\'s a other node at the front of it.',
        () async {
      const text = 'Welcome to AppFlowy Editor 🔥!';
      final document = Document.blank()
          .addParagraphs(
            1,
            builder: (index) => Delta()..insert(text),
          )
          .addParagraphs(
            1,
            builder: (index) => Delta()..insert('1.$text'),
          );
      final editorState = EditorState(document: document);

      // Welcome to AppFlowy Editor 🔥!
      // *|Welcome to AppFlowy Editor 🔥!
      final selection = Selection.collapsed(
        Position(path: [1], offset: 2),
      );
      editorState.selection = selection;
      final result = await formatNumberToNumberedList.execute(editorState);
      final after = editorState.getNodeAtPath([1])!;

      // the second line will be formatted as the bulleted list style
      expect(result, true);
      expect(after.type, 'numbered_list');
      expect(after.delta!.toPlainText(), text);
    });
  });
}
