import 'dart:async';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../util/util.dart';
import '../test_character_shortcut.dart';

void main() async {
  group('formatNumberToNumberedList', () {
    const text = 'Welcome to AppFlowy Editor 🔥!';
    // Before
    // 1|Welcome to AppFlowy Editor 🔥!
    // After
    // 1|Welcome to AppFlowy Editor 🔥!
    test('mock inputting a ` ` after the number but not dot', () async {
      unawaited(
        testFormatCharacterShortcut(
          formatNumberToNumberedList,
          '1',
          1,
          (result, before, after, editorState) {
            // nothing happens
            expect(result, false);
            expect(before.toJson(), after.toJson());
          },
        ),
      );
    });

    // Before
    // 1.|Welcome to AppFlowy Editor 🔥!
    // After
    // [numbered_list]Welcome to AppFlowy Editor 🔥!
    test(
        'mock inputting a ` ` after the number which is located at the front of the text',
        () async {
      unawaited(
        testFormatCharacterShortcut(
          formatNumberToNumberedList,
          '1.',
          2,
          (result, before, after, editorState) {
            expect(result, true);
            expect(after.delta!.toPlainText(), text);
            expect(after.type, NumberedListBlockKeys.type);
          },
        ),
      );
    });

    // Before
    // 1.W|elcome to AppFlowy Editor 🔥!
    // After
    // 1.W|elcome to AppFlowy Editor 🔥!
    test('mock inputting a ` ` in the middle of the node', () async {
      unawaited(
        testFormatCharacterShortcut(
          formatNumberToNumberedList,
          '1.',
          3,
          (result, before, after, editorState) {
            // nothing happens
            expect(result, false);
            expect(before.toJson(), after.toJson());
          },
        ),
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

    test('convert todo_list to bulleted_list', () async {
      const syntax = '1.';
      const text = 'Welcome to AppFlowy Editor 🔥!';
      unawaited(
        testFormatCharacterShortcut(
          formatNumberToNumberedList,
          syntax,
          syntax.length,
          (result, before, after, editorState) {
            expect(result, true);
            expect(after.delta!.toPlainText(), text);
            expect(after.type, NumberedListBlockKeys.type);
            expect(after.children[0].delta!.toPlainText(), '1 $text');
            expect(after.children[1].delta!.toPlainText(), '2 $text');
          },
          node: todoListNode(
            text: '$syntax$text',
            checked: false,
            children: [
              todoListNode(text: '1 $text', checked: false),
              todoListNode(text: '2 $text', checked: false),
            ],
          ),
        ),
      );
    });

    test(
        'nested todo_list to numbered_list preserves ids through undo and redo',
        () async {
      // Unlike heading, numbered lists can keep the same child shape. This
      // covers the safe in-place path for nested blocks and verifies undo/redo
      // does not regenerate parent or child ids.
      const syntax = '1.';
      const text = 'Welcome to AppFlowy Editor 🔥!';
      final child1 = todoListNode(text: '1 $text', checked: false)
        ..id = 'child-1';
      final child2 = todoListNode(text: '2 $text', checked: false)
        ..id = 'child-2';
      final node = todoListNode(
        text: '$syntax$text',
        checked: false,
        children: [child1, child2],
      )..id = 'parent';
      final document = Document.blank()..insert([0], [node]);
      final editorState = EditorState(document: document);
      editorState.selection = Selection.collapsed(
        Position(path: [0], offset: syntax.length),
      );

      final result = await formatNumberToNumberedList.execute(editorState);

      expect(result, true);
      expect(editorState.document.root.children.length, 1);
      expect(editorState.getNodeAtPath([0])!.id, 'parent');
      expect(editorState.getNodeAtPath([0])!.type, NumberedListBlockKeys.type);
      expect(editorState.getNodeAtPath([0])!.children.length, 2);
      expect(editorState.getNodeAtPath([0, 0])!.id, 'child-1');
      expect(editorState.getNodeAtPath([0, 1])!.id, 'child-2');

      editorState.undoManager.undo();

      expect(editorState.document.root.children.length, 1);
      expect(editorState.getNodeAtPath([0])!.id, 'parent');
      expect(editorState.getNodeAtPath([0])!.type, TodoListBlockKeys.type);
      expect(editorState.getNodeAtPath([0])!.children.length, 2);
      expect(editorState.getNodeAtPath([0, 0])!.id, 'child-1');
      expect(editorState.getNodeAtPath([0, 1])!.id, 'child-2');

      editorState.undoManager.redo();

      expect(editorState.document.root.children.length, 1);
      expect(editorState.getNodeAtPath([0])!.id, 'parent');
      expect(editorState.getNodeAtPath([0])!.type, NumberedListBlockKeys.type);
      expect(editorState.getNodeAtPath([0])!.children.length, 2);
      expect(editorState.getNodeAtPath([0, 0])!.id, 'child-1');
      expect(editorState.getNodeAtPath([0, 1])!.id, 'child-2');
    });

    test('nothing will happen when converting heading to numbered list',
        () async {
      const syntax = '1.';
      const text = 'Welcome to AppFlowy Editor 🔥!';
      unawaited(
        testFormatCharacterShortcut(
          formatNumberToNumberedList,
          syntax,
          syntax.length,
          (result, before, after, editorState) {
            expect(result, false);
            expect(after.delta!.toPlainText(), '$syntax$text');
            expect(after.type, HeadingBlockKeys.type);
          },
          node: headingNode(
            text: '$syntax$text',
            level: 1,
          ),
        ),
      );
    });
  });
}
