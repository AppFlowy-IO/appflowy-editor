import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../util/util.dart';

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
  });
}
