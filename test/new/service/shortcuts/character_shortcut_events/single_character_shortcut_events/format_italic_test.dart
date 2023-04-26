import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../util/util.dart';

void main() async {
  group('format the text surrounded by single underscore to italic', () {
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

    // Before
    // _AppFlowy|
    // After
    // [italic]AppFlowy
    test('_AppFlowy_ to italic AppFlowy', () async {
      const text = 'AppFlowy';
      final document = Document.blank().addParagraphs(
        1,
        builder: (index) => Delta()..insert('_$text'),
      );

      final editorState = EditorState(document: document);

      // add cursor in the end of the text
      final selection = Selection.collapsed(
        Position(path: [0], offset: text.length + 1),
      );
      editorState.selection = selection;
      // run targeted CharacterShortcutEvent
      final result = await formatUnderscoreToItalic.execute(editorState);

      expect(result, true);
      final after = editorState.getNodeAtPath([0])!;
      expect(after.delta!.toPlainText(), text);
      expect(after.delta!.toList()[0].attributes, {'italic': true});
    });

    // Before
    // App_Flowy|
    // After
    // App[italic]Flowy
    test('App_Flowy_ to App[italic]Flowy', () async {
      const text1 = 'App';
      const text2 = 'Flowy';
      final document = Document.blank().addParagraphs(
        1,
        builder: (index) => Delta()..insert('${text1}_$text2'),
      );

      final editorState = EditorState(document: document);

      final selection = Selection.collapsed(
        Position(path: [0], offset: text1.length + text2.length + 1),
      );
      editorState.selection = selection;

      final result = await formatUnderscoreToItalic.execute(editorState);

      expect(result, true);
      final after = editorState.getNodeAtPath([0])!;
      expect(after.delta!.toPlainText(), '$text1$text2');
      expect(after.delta!.toList()[0].attributes, null);
      expect(after.delta!.toList()[1].attributes, {'italic': true});
    });

    // Before
    // AppFlowy_|
    // After
    // AppFlowy__| (last underscore used to trigger the formatUnderscoreToItalic)
    test('__doule underscore change nothing', () async {
      const text = 'AppFlowy_';
      final document = Document.blank().addParagraphs(
        1,
        builder: (index) => Delta()..insert(text),
      );

      final editorState = EditorState(document: document);

      final selection = Selection.collapsed(
        Position(path: [0], offset: text.length),
      );
      editorState.selection = selection;

      final result = await formatUnderscoreToItalic.execute(editorState);

      expect(result, false);
      final after = editorState.getNodeAtPath([0])!;
      expect(after.delta!.toPlainText(), text);
    });
  });
}
