import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../util/util.dart';
import '../test_character_shortcut.dart';

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
    const text = 'Welcome to AppFlowy Editor 🔥!';
    // Before
    // 1|Welcome to AppFlowy Editor 🔥!
    // After
    // 1|Welcome to AppFlowy Editor 🔥!
    test('mock inputting a ` ` after the number but not dot', () async {
      testFormatCharacterShortcut(
        formatNumberToNumberedList,
        '1',
        1,
        (result, before, after) {
          // nothing happens
          expect(result, false);
          expect(before.toJson(), after.toJson());
        },
        text: text,
      );
    });

    // Before
    // 1.|Welcome to AppFlowy Editor 🔥!
    // After
    // [numbered_list]Welcome to AppFlowy Editor 🔥!
    test(
        'mock inputting a ` ` after the number which is located at the front of the text',
        () async {
      testFormatCharacterShortcut(
        formatNumberToNumberedList,
        '1.',
        2,
        (result, before, after) {
          expect(result, true);
          expect(after.delta!.toPlainText(), text);
          expect(after.type, NumberedListBlockKeys.type);
        },
        text: text,
      );
    });

    // Before
    // 1.W|elcome to AppFlowy Editor 🔥!
    // After
    // 1.W|elcome to AppFlowy Editor 🔥!
    test('mock inputting a ` ` in the middle of the node', () async {
      testFormatCharacterShortcut(
        formatNumberToNumberedList,
        '1.',
        3,
        (result, before, after) {
          // nothing happens
          expect(result, false);
          expect(before.toJson(), after.toJson());
        },
        text: text,
      );
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
          .addParagraph(
            initialText: text,
          )
          .addParagraph(
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
      expect(after.type, NumberedListBlockKeys.type);
      expect(after.delta!.toPlainText(), text);
    });

    // Before
    // 1. Welcome to AppFlowy Editor 🔥!
    // 2.|
    // After
    // 1. Welcome to AppFlowy Editor 🔥!
    // 2. [numbered_list]
    test('insert 2. after 1.', () async {
      const text = 'Welcome to AppFlowy Editor 🔥!';
      final document = Document.blank()
          .addNode(
            NumberedListBlockKeys.type,
            initialText: text,
            decorator: (index, node) => node.updateAttributes(
              {
                NumberedListBlockKeys.number: 1,
              },
            ),
          )
          .addParagraph(
            initialText: '2.',
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
      expect(after.type, NumberedListBlockKeys.type);
      expect(after.delta!.toPlainText(), '');
    });

    // Before
    // 1. Welcome to AppFlowy Editor 🔥!
    // 2.|
    // After
    // 1. Welcome to AppFlowy Editor 🔥!
    // 2. [numbered_list]
    test('insert 3. after 1.', () async {
      const text = 'Welcome to AppFlowy Editor 🔥!';
      final document = Document.blank()
          .addNode(
            NumberedListBlockKeys.type,
            initialText: text,
            decorator: (index, node) => node.updateAttributes(
              {
                NumberedListBlockKeys.number: 1,
              },
            ),
          )
          .addParagraph(
            initialText: '3.',
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
      expect(result, false);
      expect(after.type, ParagraphBlockKeys.type);
      expect(after.delta!.toPlainText(), '3.');
    });
  });
}
