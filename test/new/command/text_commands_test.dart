import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../infra/testable_editor.dart';
import '../util/util.dart';

void main() async {
  group('formatDelta', () {
    const text = 'Welcome to AppFlowy Editor 🔥!';

    // Welcome |to AppFlowy Editor 🔥!
    test('format delta in collapsed selection', () async {
      final document = Document.blank().addParagraph(
        initialText: text,
      );
      final editorState = EditorState(document: document);

      // Welcome |to AppFlowy Editor 🔥!
      const welcome = 'Welcome ';
      final selection = Selection.collapsed(
        Position(path: [0], offset: welcome.length),
      );
      editorState.selection = selection;

      final before = editorState.getNodeAtPath([0]);
      await editorState.formatDelta(selection, {
        'bold': true,
      });
      final after = editorState.getNodeAtPath([0]);

      expect(before?.toJson(), after?.toJson());
      expect(editorState.selection, selection);
    });

    // Before
    // Welcome to |AppFlowy| Editor 🔥!
    // After
    // Welcome to <bold>AppFlowy</bold> Editor 🔥!
    test('format delta in single selection', () async {
      final document = Document.blank().addParagraph(
        initialText: text,
      );
      final editorState = EditorState(document: document);

      // Welcome |to AppFlowy Editor 🔥!
      const welcomeTo = 'Welcome to ';
      const appFlowy = 'AppFlowy';
      final selection = Selection.single(
        path: [0],
        startOffset: welcomeTo.length,
        endOffset: welcomeTo.length + appFlowy.length,
      );
      editorState.selection = selection;

      await editorState.formatDelta(selection, {
        'bold': true,
      });
      final after = editorState.getNodeAtPath([0]);

      final result = after?.allSatisfyInSelection(selection, (delta) {
        final textInserts = delta.whereType<TextInsert>();
        return textInserts
            .every((element) => element.attributes?['bold'] == true);
      });
      expect(result, true);
      expect(editorState.selection, selection);
    });

    // Welcome to |AppFlowy Editor 🔥!
    // Welcome to |AppFlowy Editor 🔥!
    // After
    // Welcome to <bold>AppFlowy Editor 🔥!</bold>
    // <bold>Welcome to </bold>AppFlowy Editor 🔥!
    test('format delta in not single selection', () async {
      final document = Document.blank().addParagraph(
        initialText: text,
      );
      final editorState = EditorState(document: document);

      // Welcome |to AppFlowy Editor 🔥!
      const welcomeTo = 'Welcome to ';
      final selection = Selection(
        start: Position(path: [0], offset: welcomeTo.length),
        end: Position(path: [1], offset: welcomeTo.length),
      );
      editorState.selection = selection;

      await editorState.formatDelta(selection, {
        'bold': true,
      });

      final after = editorState.getNodesInSelection(selection);
      final result = after.allSatisfyInSelection(selection, (delta) {
        final textInserts = delta.whereType<TextInsert>();
        return textInserts
            .every((element) => element.attributes?['bold'] == true);
      });
      expect(result, true);
      expect(editorState.selection, selection);
    });
  });

  group('insertNewLine', () {
    const text = 'Welcome to AppFlowy Editor 🔥!';

    // Before
    // Welcome |to AppFlowy Editor 🔥!
    // After
    // Welcome
    // |AppFlowy Editor 🔥!
    test('insert new line at the node which  doesn\'t contains children',
        () async {
      final document = Document.blank().addParagraph(
        initialText: text,
      );
      final editorState = EditorState(document: document);

      // Welcome |to AppFlowy Editor 🔥!
      const welcome = 'Welcome ';
      final selection = Selection.collapsed(
        Position(path: [0], offset: welcome.length),
      );
      editorState.selection = selection;
      editorState.insertNewLine();

      expect(editorState.getNodeAtPath([0])?.delta?.toPlainText(), welcome);
      expect(
        editorState.getNodeAtPath([1])?.delta?.toPlainText(),
        text.substring(welcome.length),
      );
    });

    // Before
    // Welcome |to AppFlowy Editor 🔥!
    //    Welcome to AppFlowy Editor 🔥!
    // After
    // Welcome |
    // AppFlowy Editor 🔥!
    //    Welcome to AppFlowy Editor 🔥!
    test('insert new line at the node which contains children', () async {
      final document = Document.blank().addParagraph(
        initialText: text,
        decorator: (index, node) {
          node.addParagraph(
            initialText: text,
          );
        },
      );
      final editorState = EditorState(document: document);

      // 0. Welcome |to AppFlowy Editor 🔥!
      const welcome = 'Welcome ';
      final selection = Selection.collapsed(
        Position(path: [0], offset: welcome.length),
      );
      editorState.selection = selection;
      editorState.insertNewLine();

      expect(editorState.getNodeAtPath([0])?.delta?.toPlainText(), welcome);
      expect(editorState.getNodeAtPath([0, 0]), null);
      expect(
        editorState.getNodeAtPath([1])?.delta?.toPlainText(),
        text.substring(welcome.length),
      );
      expect(editorState.getNodeAtPath([1, 0])?.delta?.toPlainText(), text);
    });

    test('insert new line preserve direction', () async {
      final document = Document.blank().addParagraph(
        initialText: text,
        decorator: (index, node) => node.updateAttributes(
          {ParagraphBlockKeys.textDirection: blockComponentTextDirectionRTL},
        ),
      );
      final editorState = EditorState(document: document);

      final selection = Selection.collapsed(
        Position(path: [0], offset: text.length),
      );
      editorState.selection = selection;
      await editorState.insertNewLine();

      final textDirection = editorState
          .getNodeAtPath([1])?.attributes[ParagraphBlockKeys.textDirection];
      expect(
        textDirection,
        blockComponentTextDirectionRTL,
      );
    });
  });

  group('insertText', () {
    const text = 'Welcome to AppFlowy Editor 🔥!';

    /// Before
    /// |
    /// Welcome to AppFlowy Editor 🔥!
    ///
    /// After
    /// Hello|
    /// Welcome to AppFlowy Editor 🔥!
    test('insertText', () async {
      final document = Document.blank()
          .addParagraph(
            initialText: '',
          )
          .addParagraph(
            initialText: text,
            decorator: (index, node) {
              node.addParagraph(
                initialText: text,
              );
            },
          );
      final editorState = EditorState(document: document);

      const hello = 'Hello';
      await editorState.insertText(0, hello, path: [0]);

      expect(editorState.getNodeAtPath([0])?.delta?.toPlainText(), hello);
    });

    test('insertTextAtCurrentSelection', () async {
      final document = Document.blank()
          .addParagraph(
            initialText: '',
          )
          .addParagraph(
            initialText: text,
            decorator: (index, node) {
              node.addParagraph(
                initialText: text,
              );
            },
          );
      final selection = Selection.collapsed(
        Position(path: [0], offset: 0),
      );
      final editorState = EditorState(document: document);
      editorState.selection = selection;

      const hello = 'Hello';
      await editorState.insertTextAtCurrentSelection(hello);

      expect(editorState.getNodeAtPath([0])?.delta?.toPlainText(), hello);
      expect(
        editorState.selection,
        Selection.collapsed(
          Position(path: [0], offset: hello.length),
        ),
      );
    });
  });

  group('getNodesInSelection', () {
    const text = 'Welcome to AppFlowy Editor 🔥!';

    // Welcome| to AppFlowy Editor 🔥!
    test('get nodes in collapsed selection', () async {
      final document = Document.blank().addParagraph(
        initialText: text,
      );
      // Welcome| to AppFlowy Editor 🔥!
      final selection = Selection.collapsed(
        Position(path: [0], offset: 4),
      );
      final editorState = EditorState(document: document);
      editorState.selection = selection;
      final texts = editorState.getTextInSelection(selection);
      expect(texts, []);
    });

    // Welcome to |AppFlowy| Editor 🔥!
    test('get nodes in single selection', () async {
      final document = Document.blank().addParagraph(
        initialText: text,
      );
      // Welcome to |AppFlowy| Editor 🔥!
      final selection = Selection.single(
        path: [0],
        startOffset: 'Welcome to '.length,
        endOffset: 'Welcome to AppFlowy'.length,
      );
      final editorState = EditorState(document: document);
      editorState.selection = selection;
      final texts = editorState.getTextInSelection(selection);
      expect(texts, ['AppFlowy']);
    });

    // Wel|come
    // To
    // App|Flowy
    test('get nodes in multi selection', () async {
      final document = Document.blank()
          .addParagraph(
            initialText: 'Welcome',
          )
          .addParagraph(
            initialText: 'To',
          )
          .addParagraph(
            initialText: 'AppFlowy',
          );
      // Wel|come
      // To
      // App|Flowy
      final selection = Selection(
        start: Position(path: [0], offset: 3),
        end: Position(path: [2], offset: 3),
      );
      final editorState = EditorState(document: document);
      editorState.selection = selection;
      final texts = editorState.getTextInSelection(selection);
      expect(texts, ['come', 'To', 'App']);
    });
  });

  group('toggle style', () {
    testWidgets('toggle the style if the previous character isn\'t formatted',
        (tester) async {
      const text = '';
      final editor = tester.editor..addParagraph(initialText: text);

      await editor.startTesting();
      await editor.updateSelection(
        Selection.single(path: [0], startOffset: text.length),
      );

      // toggle bold, italic, underline
      final keys = [
        LogicalKeyboardKey.keyB,
        LogicalKeyboardKey.keyI,
        LogicalKeyboardKey.keyU,
      ];
      for (final key in keys) {
        await editor.pressKey(
          key: key,
          isControlPressed: !Platform.isMacOS,
          isMetaPressed: Platform.isMacOS,
        );
      }

      await editor.ime.insertText('Hello');
      final delta1 = editor.nodeAtPath([0])!.delta!;
      expect(delta1.toJson(), [
        {
          "insert": "Hello",
          "attributes": {"bold": true, "italic": true, "underline": true}
        }
      ]);

      // cancel the toggled style
      for (final key in keys) {
        await editor.pressKey(
          key: key,
          isControlPressed: !Platform.isMacOS,
          isMetaPressed: Platform.isMacOS,
        );
      }

      await editor.ime.insertText('World');
      final delta2 = editor.nodeAtPath([0])!.delta!;
      expect(delta2.toJson(), [
        {
          "insert": "Hello",
          "attributes": {"bold": true, "italic": true, "underline": true}
        },
        {
          "insert": "World",
          "attributes": {"bold": false, "italic": false, "underline": false}
        },
      ]);

      expect(editor.editorState.toggledStyle, isEmpty);
      await editor.dispose();
    });

    testWidgets('toggle twice to reset the toggled style', (tester) async {
      const text = '';
      final editor = tester.editor..addParagraph(initialText: text);

      await editor.startTesting();
      await editor.updateSelection(
        Selection.single(path: [0], startOffset: text.length),
      );

      // toggle bold, italic, underline
      final keys = [
        LogicalKeyboardKey.keyB,
        LogicalKeyboardKey.keyI,
        LogicalKeyboardKey.keyU,
      ];
      for (final key in keys) {
        await editor.pressKey(
          key: key,
          isControlPressed: !Platform.isMacOS,
          isMetaPressed: Platform.isMacOS,
        );
      }

      // reset
      for (final key in keys) {
        await editor.pressKey(
          key: key,
          isControlPressed: !Platform.isMacOS,
          isMetaPressed: Platform.isMacOS,
        );
      }

      await editor.ime.insertText('Hello');
      final delta1 = editor.nodeAtPath([0])!.delta!;
      expect(delta1.toJson(), [
        {
          "insert": "Hello",
          "attributes": {"bold": false, "italic": false, "underline": false}
        }
      ]);

      expect(editor.editorState.toggledStyle, isEmpty);
      await editor.dispose();
    });
  });
}
