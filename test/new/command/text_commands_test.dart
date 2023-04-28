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
