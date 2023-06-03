import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/service/internal_key_event_handlers/whitespace_handler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../new/infra/testable_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('white_space_handler.dart', () {
    // Before
    //
    // Welcome to Appflowy 😁
    // Welcome to Appflowy 😁
    // Welcome to Appflowy 😁
    // Welcome to Appflowy 😁
    // Welcome to Appflowy 😁
    // Welcome to Appflowy 😁
    //
    // After
    // [h1]Welcome to Appflowy 😁
    // [h2]Welcome to Appflowy 😁
    // [h3]Welcome to Appflowy 😁
    // [h4]Welcome to Appflowy 😁
    // [h5]Welcome to Appflowy 😁
    // [h6]Welcome to Appflowy 😁
    //
    testWidgets('Presses whitespace key after #*', (tester) async {
      const maxSignCount = 6;
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor;
      for (var i = 1; i <= maxSignCount; i++) {
        editor.addParagraph(initialText: '${'#' * i}$text');
      }
      await editor.startTesting();

      for (var i = 1; i <= maxSignCount; i++) {
        await editor.updateSelection(
          Selection.single(path: [i - 1], startOffset: i),
        );
        await editor.pressKey(key: LogicalKeyboardKey.space);

        final node = editor.nodeAtPath([i - 1])!;
        expect(node.type, 'heading');
        expect(node.attributes[HeadingBlockKeys.level], i);
      }

      await editor.dispose();
    });

    // Before
    //
    // Welcome to Appflowy 😁
    // Welcome to Appflowy 😁
    // Welcome to Appflowy 😁
    // Welcome to Appflowy 😁
    // Welcome to Appflowy 😁
    // Welcome to Appflowy 😁
    //
    // After
    // [h1]##Welcome to Appflowy 😁
    // [h2]##Welcome to Appflowy 😁
    // [h3]##Welcome to Appflowy 😁
    // [h4]##Welcome to Appflowy 😁
    // [h5]##Welcome to Appflowy 😁
    // [h6]##Welcome to Appflowy 😁
    //
    testWidgets('Presses whitespace key inside #*', (tester) async {
      const maxSignCount = 6;
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor;
      for (var i = 1; i <= maxSignCount; i++) {
        editor.addParagraph(initialText: '${'###' * i}$text');
      }
      await editor.startTesting();

      for (var i = 1; i <= maxSignCount; i++) {
        await editor.updateSelection(
          Selection.single(path: [i - 1], startOffset: i),
        );
        await editor.pressKey(key: LogicalKeyboardKey.space);

        final node = editor.nodeAtPath([i - 1])!;

        expect(node.type, 'heading');
        // BuiltInAttributeKey.h1 ~ BuiltInAttributeKey.h6
        expect(node.attributes[HeadingBlockKeys.level], i);
        expect(node.delta!.toPlainText().startsWith('##'), true);
      }

      await editor.dispose();
    });

    // Before
    //
    // Welcome to Appflowy 😁
    //
    // After
    // [h1 ~ h6]##Welcome to Appflowy 😁
    //
    testWidgets('Presses whitespace key in heading styled text',
        (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor..addParagraph(initialText: text);

      await editor.startTesting();

      const maxSignCount = 6;
      for (var i = 1; i <= maxSignCount; i++) {
        await editor.updateSelection(
          Selection.single(path: [0], startOffset: 0),
        );

        var node = editor.nodeAtPath([0])!;
        await editor.editorState.insertText(0, '#' * i, node: node);
        await editor.pressKey(key: LogicalKeyboardKey.space);
        node = editor.nodeAtPath([0])!;

        expect(node.type, 'heading');
        // BuiltInAttributeKey.h2 ~ BuiltInAttributeKey.h6
        expect(node.attributes[HeadingBlockKeys.level], i);
      }

      await editor.dispose();
    });

    testWidgets('Presses whitespace key after (un)checkbox symbols',
        (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor..addParagraph(initialText: text);
      await editor.startTesting();

      for (final symbol in unCheckboxListSymbols) {
        await editor.updateSelection(
          Selection.single(path: [0], startOffset: 0),
        );
        await editor.pressKey(character: symbol);
        await editor.pressKey(key: LogicalKeyboardKey.space);
        final node = editor.nodeAtPath([0])!;
        expect(node.type, 'todo_list');
        expect(node.attributes.check, false);
      }

      await editor.dispose();
    });

    testWidgets('Presses whitespace key after checkbox symbols',
        (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor..addParagraph(initialText: text);
      await editor.startTesting();

      for (final symbol in checkboxListSymbols) {
        await editor.updateSelection(
          Selection.single(path: [0], startOffset: 0),
        );
        await editor.pressKey(character: symbol);
        await editor.pressKey(key: LogicalKeyboardKey.space);
        final node = editor.nodeAtPath([0])!;
        expect(node.type, 'todo_list');
        expect(node.attributes[TodoListBlockKeys.checked], true);
      }
      await editor.dispose();
    });

    testWidgets('Presses whitespace key after bulleted list', (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor..addParagraph(initialText: text);
      await editor.startTesting();

      for (final symbol in bulletedListSymbols) {
        await editor.updateSelection(
          Selection.single(path: [0], startOffset: 0),
        );
        await editor.pressKey(character: symbol);
        await editor.pressKey(key: LogicalKeyboardKey.space);
        final node = editor.nodeAtPath([0])!;
        expect(node.type, 'bulleted_list');
      }
      await editor.dispose();
    });

    testWidgets('Presses whitespace key in edge cases', (tester) async {
      const text = '';
      final editor = tester.editor..addParagraph(initialText: text);
      await editor.startTesting();

      var node = editor.nodeAtPath([0])!;
      await editor.updateSelection(
        Selection.single(path: [0], startOffset: 0),
      );

      await editor.editorState.insertText(0, '"', node: node);
      await editor.pressKey(key: LogicalKeyboardKey.space);
      node = editor.nodeAtPath([0])!;
      expect(node.type, 'quote');

      await editor.editorState.insertText(0, '*', node: node);
      await editor.pressKey(key: LogicalKeyboardKey.space);
      node = editor.nodeAtPath([0])!;
      expect(node.type, 'bulleted_list');

      await editor.editorState.insertText(0, '[]', node: node);
      await editor.pressKey(key: LogicalKeyboardKey.space);
      node = editor.nodeAtPath([0])!;
      expect(node.type, 'todo_list');
      expect(node.attributes.check, false);

      await editor.editorState.insertText(0, '1.', node: node);
      await editor.pressKey(key: LogicalKeyboardKey.space);
      node = editor.nodeAtPath([0])!;
      expect(node.type, 'numbered_list');

      await editor.editorState.insertText(0, '#', node: node);
      await editor.pressKey(key: LogicalKeyboardKey.space);
      node = editor.nodeAtPath([0])!;
      expect(node.type, 'heading');

      await editor.editorState.insertText(0, '[x]', node: node);
      await editor.pressKey(key: LogicalKeyboardKey.space);
      node = editor.nodeAtPath([0])!;
      expect(node.type, 'todo_list');
      expect(node.attributes[TodoListBlockKeys.checked], true);

      const insertedText = '[]AppFlowy';
      await editor.editorState.insertText(0, insertedText, node: node);
      await editor.pressKey(key: LogicalKeyboardKey.space);
      node = editor.nodeAtPath([0])!;
      expect(node.type, 'todo_list');
      expect(node.attributes[TodoListBlockKeys.checked], true);
      expect(node.delta!.toPlainText(), '$insertedText ');

      await editor.dispose();
    });

    testWidgets('Presses # at the end of the text', (tester) async {
      const text = 'Welcome to Appflowy 😁 #';
      final editor = tester.editor..addParagraph(initialText: text);
      await editor.startTesting();

      final node = editor.nodeAtPath([0])!;
      await editor.updateSelection(
        Selection.single(path: [0], startOffset: text.length),
      );
      await editor.pressKey(key: LogicalKeyboardKey.space);
      expect(node.type, 'paragraph');
      expect(node.delta!.toPlainText(), '$text ');

      await editor.dispose();
    });

    group('convert double quote to blockquote', () {
      testWidgets('" AppFlowy to blockquote AppFlowy', (tester) async {
        const text = 'AppFlowy';
        final editor = tester.editor..addParagraph(initialText: '');
        await editor.startTesting();
        await editor.updateSelection(
          Selection.single(path: [0], startOffset: 0),
        );

        var node = editor.nodeAtPath([0])!;
        await editor.editorState.insertText(0, '"', node: node);
        await editor.pressKey(key: LogicalKeyboardKey.space);
        node = editor.nodeAtPath([0])!;
        expect(node.type, 'quote');
        for (var i = 0; i < text.length; i++) {
          await editor.editorState.insertText(i, text[i], node: node);
        }
        expect(node.delta!.toPlainText(), 'AppFlowy');

        await editor.dispose();
      });

      testWidgets('AppFlowy > nothing changes', (tester) async {
        const text = 'AppFlowy >';
        final editor = tester.editor..addParagraph(initialText: '');
        await editor.startTesting();
        await editor.updateSelection(
          Selection.single(path: [0], startOffset: 0),
        );

        final node = editor.nodeAtPath([0])!;
        for (var i = 0; i < text.length; i++) {
          await editor.editorState.insertText(i, text[i], node: node);
        }
        await editor.pressKey(key: LogicalKeyboardKey.space);
        final isQuote = node.type == 'quote';
        expect(isQuote, false);
        expect(node.delta!.toPlainText(), '$text ');

        await editor.dispose();
      });

      testWidgets('" in front of text to blockquote', (tester) async {
        const text = 'AppFlowy';
        final editor = tester.editor..addParagraph(initialText: '');
        await editor.startTesting();
        await editor.updateSelection(
          Selection.single(path: [0], startOffset: 0),
        );
        var node = editor.nodeAtPath([0])!;
        for (var i = 0; i < text.length; i++) {
          await editor.editorState.insertText(i, text[i], node: node);
        }
        await editor.updateSelection(
          Selection.single(path: [0], startOffset: 0),
        );
        await editor.editorState.insertText(0, '"', node: node);
        await editor.pressKey(key: LogicalKeyboardKey.space);

        node = editor.nodeAtPath([0])!;
        final isQuote = node.type == 'quote';
        expect(isQuote, true);
        expect(node.delta!.toPlainText(), text);

        await editor.dispose();
      });
    });
  });
}
