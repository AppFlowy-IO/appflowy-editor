import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../util/util.dart';

void main() async {
  group('format the text surrounded by single backquote to code', () {
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
    // `AppFlowy|
    // After
    // [code]AppFlowy
    test('`AppFlowy` to code AppFlowy', () async {
      const text = 'AppFlowy';
      final document = Document.blank().addParagraphs(
        1,
        builder: (index) => Delta()..insert('`$text'),
      );

      final editorState = EditorState(document: document);

      // add cursor in the end of the text
      final selection = Selection.collapsed(
        Position(path: [0], offset: text.length + 1),
      );
      editorState.selection = selection;
      // run targeted CharacterShortcutEvent
      final result = await formatBackquoteToCode.execute(editorState);

      expect(result, true);
      final after = editorState.getNodeAtPath([0])!;
      expect(after.delta!.toPlainText(), text);
      expect(after.delta!.toList()[0].attributes, {'code': true});
    });

    // Before
    // App`Flowy|
    // After
    // App[code]Flowy
    test('App`Flowy` to App[code]Flowy', () async {
      const text1 = 'App';
      const text2 = 'Flowy';
      final document = Document.blank().addParagraphs(
        1,
        builder: (index) => Delta()..insert('$text1`$text2'),
      );

      final editorState = EditorState(document: document);

      final selection = Selection.collapsed(
        Position(path: [0], offset: text1.length + text2.length + 1),
      );
      editorState.selection = selection;

      final result = await formatBackquoteToCode.execute(editorState);

      expect(result, true);
      final after = editorState.getNodeAtPath([0])!;
      expect(after.delta!.toPlainText(), '$text1$text2');
      expect(after.delta!.toList()[0].attributes, null);
      expect(after.delta!.toList()[1].attributes, {'code': true});
    });

    // Before
    // AppFlowy`|
    // After
    // AppFlowy``| (last backquote used to trigger the formatBackquoteToCode)
    test('`` double backquote change nothing', () async {
      const text = 'AppFlowy`';
      final document = Document.blank().addParagraphs(
        1,
        builder: (index) => Delta()..insert(text),
      );

      final editorState = EditorState(document: document);

      final selection = Selection.collapsed(
        Position(path: [0], offset: text.length),
      );
      editorState.selection = selection;

      final result = await formatBackquoteToCode.execute(editorState);

      expect(result, false);
      final after = editorState.getNodeAtPath([0])!;
      expect(after.delta!.toPlainText(), text);
    });

    // Before
    // <code>`AppFlowy</code>
    // After
    // AppFlowy
    test('remove the format', () async {
      const text = '`AppFlowy';
      final document = Document.blank().addParagraphs(
        1,
        builder: (index) => Delta()
          ..insert(
            text,
            attributes: {
              'code': true,
            },
          ),
      );

      final editorState = EditorState(document: document);

      final selection = Selection.collapsed(
        Position(path: [0], offset: text.length),
      );
      editorState.selection = selection;

      final result = await formatBackquoteToCode.execute(editorState);

      expect(result, true);
      final after = editorState.getNodeAtPath([0])!;
      expect(
        after.delta!.toPlainText(),
        text.substring(1),
      ); // remove the first backquote
      final isCode =
          after.delta!.everyAttributes((element) => element['code'] == true);
      expect(
        isCode,
        false,
      );
    });
  });
}
