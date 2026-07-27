import 'dart:async';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../util/util.dart';
import '../test_character_shortcut.dart';

void main() async {
  group('formate', () {
    const text = 'Welcome to AppFlowy Editor 🔥!';

    // Before
    // ''
    // After
    // ' '
    test('mock inputting a ` ` after the >', () async {
      unawaited(
        testFormatCharacterShortcut(
          formatSignToHeading,
          '',
          0,
          (result, before, after, editorState) {
            expect(result, false);
            expect(before.delta!.toPlainText(), '');
            expect(after.delta!.toPlainText(), '');
            expect(after.type != HeadingBlockKeys.type, true);
          },
          text: '',
        ),
      );
    });

    // Before
    // #|Welcome to AppFlowy Editor 🔥!
    // After
    // [heading] Welcome to AppFlowy Editor 🔥!
    test('mock inputting a ` ` after the #', () async {
      for (var i = 1; i <= 6; i++) {
        unawaited(
          testFormatCharacterShortcut(
            formatSignToHeading,
            '#' * i,
            i,
            (result, before, after, editorState) {
              expect(result, true);
              expect(after.delta!.toPlainText(), text);
              expect(after.type, 'heading');
            },
          ),
        );
      }
    });

    // Before
    // #######|Welcome to AppFlowy Editor 🔥!
    // After
    // #######|Welcome to AppFlowy Editor 🔥!
    test('mock inputting a ` ` after the #', () async {
      unawaited(
        testFormatCharacterShortcut(
          formatSignToHeading,
          '#' * 7,
          7,
          (result, before, after, editorState) {
            // nothing happens
            expect(result, false);
            expect(before.toJson(), after.toJson());
          },
        ),
      );
    });

    // Before
    // >W|elcome to AppFlowy Editor 🔥!
    // After
    // >W|elcome to AppFlowy Editor 🔥!
    test('mock inputting a ` ` in the middle of the node', () async {
      unawaited(
        testFormatCharacterShortcut(
          formatSignToHeading,
          '#',
          2,
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
    // >|Welcome to AppFlowy Editor 🔥!
    // After
    // Welcome to AppFlowy Editor 🔥!
    //[quote] Welcome to AppFlowy Editor 🔥!
    test(
        'mock inputting a ` ` in the middle of the node, and there\'s a other node at the front of it.',
        () async {
      const text = 'Welcome to AppFlowy Editor 🔥!';
      final document = Document.blank()
          .addParagraph(
            initialText: text,
          )
          .addParagraph(
            initialText: '#$text',
          );
      final editorState = EditorState(document: document);

      // Welcome to AppFlowy Editor 🔥!
      // *|Welcome to AppFlowy Editor 🔥!
      final selection = Selection.collapsed(
        Position(path: [1], offset: 1),
      );
      editorState.selection = selection;
      final result = await formatSignToHeading.execute(editorState);
      final after = editorState.getNodeAtPath([1])!;

      // the second line will be formatted as the bulleted list style
      expect(result, true);
      expect(after.type, 'heading');
      expect(after.delta!.toPlainText(), text);
    });

    test('convert bulleted_list to heading', () async {
      const syntax = '#';
      const text = 'Welcome to AppFlowy Editor 🔥!';
      await testFormatCharacterShortcut(
        formatSignToHeading,
        syntax,
        syntax.length,
        (result, before, after, editorState) {
          expect(result, true);
          expect(after.delta!.toPlainText(), text);
          expect(after.type, HeadingBlockKeys.type);
          expect(after.attributes[HeadingBlockKeys.level], 1);
          expect(after.children.isEmpty, true);
          expect(after.next!.delta!.toPlainText(), '1 $text');
          expect(after.next!.next!.delta!.toPlainText(), '2 $text');
        },
        node: bulletedListNode(
          text: '$syntax$text',
          children: [
            bulletedListNode(text: '1 $text'),
            bulletedListNode(text: '2 $text'),
          ],
        ),
      );
    });

    test('paragraph to heading preserves id through undo and redo', () async {
      // No children: this is the safe in-place path. The markdown shortcut
      // should change the type to heading without replacing the node id.
      const syntax = '#';
      const text = 'Welcome to AppFlowy Editor 🔥!';
      final node = paragraphNode(text: '$syntax$text')..id = 'paragraph-id';
      final document = Document.blank()..insert([0], [node]);
      final editorState = EditorState(document: document);
      editorState.selection = Selection.collapsed(
        Position(path: [0], offset: syntax.length),
      );

      final result = await formatSignToHeading.execute(editorState);

      expect(result, true);
      expect(editorState.document.root.children.length, 1);
      expect(editorState.getNodeAtPath([0])!.id, 'paragraph-id');
      expect(editorState.getNodeAtPath([0])!.type, HeadingBlockKeys.type);
      expect(editorState.getNodeAtPath([0])!.delta!.toPlainText(), text);

      editorState.undoManager.undo();

      expect(editorState.document.root.children.length, 1);
      expect(editorState.getNodeAtPath([0])!.id, 'paragraph-id');
      expect(editorState.getNodeAtPath([0])!.type, ParagraphBlockKeys.type);
      expect(
        editorState.getNodeAtPath([0])!.delta!.toPlainText(),
        '$syntax$text',
      );

      editorState.undoManager.redo();

      expect(editorState.document.root.children.length, 1);
      expect(editorState.getNodeAtPath([0])!.id, 'paragraph-id');
      expect(editorState.getNodeAtPath([0])!.type, HeadingBlockKeys.type);
      expect(editorState.getNodeAtPath([0])!.delta!.toPlainText(), text);
    });

    test('convert numbered_list to heading flattens children', () async {
      // Historical AppFlowy PR #6516 covered this corner case: heading blocks
      // cannot contain children, so nested list children must be flattened into
      // siblings instead of being preserved inside the converted heading.
      const syntax = '#';
      const text = 'Welcome to AppFlowy Editor 🔥!';
      await testFormatCharacterShortcut(
        formatSignToHeading,
        syntax,
        syntax.length,
        (result, before, after, editorState) {
          expect(result, true);
          expect(after.delta!.toPlainText(), text);
          expect(after.type, HeadingBlockKeys.type);
          expect(after.attributes[HeadingBlockKeys.level], 1);
          expect(after.children.isEmpty, true);
          expect(after.next!.delta!.toPlainText(), '1 $text');
          expect(after.next!.type, NumberedListBlockKeys.type);
          expect(after.next!.next!.delta!.toPlainText(), '2 $text');
          expect(after.next!.next!.type, NumberedListBlockKeys.type);
        },
        node: numberedListNode(
          delta: Delta()..insert('$syntax$text'),
          children: [
            numberedListNode(delta: Delta()..insert('1 $text')),
            numberedListNode(delta: Delta()..insert('2 $text')),
          ],
        ),
      );
    });

    test('undo and redo numbered_list to heading child flattening', () async {
      // The same historical report also called out undo risk. The fallback
      // insert/delete path must undo back to one nested list and redo back to a
      // childless heading followed by flattened list siblings.
      const syntax = '#';
      const text = 'Welcome to AppFlowy Editor 🔥!';
      final child1 = numberedListNode(delta: Delta()..insert('1 $text'))
        ..id = 'child-1';
      final child2 = numberedListNode(delta: Delta()..insert('2 $text'))
        ..id = 'child-2';
      final node = numberedListNode(
        delta: Delta()..insert('$syntax$text'),
        children: [child1, child2],
      )..id = 'parent';
      final document = Document.blank()..insert([0], [node]);
      final editorState = EditorState(document: document);
      editorState.selection = Selection.collapsed(
        Position(path: [0], offset: syntax.length),
      );

      final result = await formatSignToHeading.execute(editorState);

      expect(result, true);
      expect(editorState.document.root.children.length, 3);
      expect(editorState.getNodeAtPath([0])!.type, HeadingBlockKeys.type);
      expect(editorState.getNodeAtPath([0])!.children, isEmpty);
      expect(editorState.getNodeAtPath([1])!.type, NumberedListBlockKeys.type);
      expect(editorState.getNodeAtPath([2])!.type, NumberedListBlockKeys.type);

      editorState.undoManager.undo();

      expect(editorState.document.root.children.length, 1);
      expect(editorState.getNodeAtPath([0])!.id, 'parent');
      expect(editorState.getNodeAtPath([0])!.type, NumberedListBlockKeys.type);
      expect(
        editorState.getNodeAtPath([0])!.delta!.toPlainText(),
        '$syntax$text',
      );
      expect(editorState.getNodeAtPath([0])!.children.length, 2);
      expect(editorState.getNodeAtPath([0, 0])!.id, 'child-1');
      expect(editorState.getNodeAtPath([0, 1])!.id, 'child-2');

      editorState.undoManager.redo();

      expect(editorState.document.root.children.length, 3);
      expect(editorState.getNodeAtPath([0])!.type, HeadingBlockKeys.type);
      expect(editorState.getNodeAtPath([0])!.children, isEmpty);
      expect(editorState.getNodeAtPath([1])!.type, NumberedListBlockKeys.type);
      expect(editorState.getNodeAtPath([1])!.delta!.toPlainText(), '1 $text');
      expect(editorState.getNodeAtPath([2])!.type, NumberedListBlockKeys.type);
      expect(editorState.getNodeAtPath([2])!.delta!.toPlainText(), '2 $text');
    });
  });
}
