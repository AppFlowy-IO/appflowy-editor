import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../util/util.dart';

void main() async {
  group('format the text in markdown link syntax to appflowy href', () {
    // Before
    // [AppFlowy](appflowy.com|
    // After
    // [href:appflowy.com]AppFlowy
    test('[AppFlowy](appflowy.com) to format AppFlowy as link', () async {
      const text = 'AppFlowy';
      const link = 'appflowy.com';
      final document = Document.blank().addParagraphs(
        1,
        builder: (index) => Delta()..insert('[$text]($link'),
      );

      final editorState = EditorState(document: document);

      // add cursor in the end of the text
      final selection = Selection.collapsed(
        Position(path: [0], offset: text.length + 1),
      );
      editorState.selection = selection;
      // run targeted CharacterShortcutEvent
      final result = await formatMarkdownLinkToLink.execute(editorState);

      expect(result, true);
      final after = editorState.getNodeAtPath([0])!;
      expect(after.delta!.toPlainText(), text);
      expect(
        after.delta!.toList()[0].attributes,
        {AppFlowyRichTextKeys.href: link},
      );
    });

    // Before
    // App[Flowy](flowy.com|
    // After
    // App[href:appflowy.com]Flowy
    test('App[Flowy](appflowy.com) to App[href:appflowy.com]Flowy', () async {
      const text1 = 'App';
      const text2 = 'Flowy';
      const link = 'appflowy.com';
      final document = Document.blank().addParagraphs(
        1,
        builder: (index) => Delta()..insert('$text1[$text2]($link'),
      );

      final editorState = EditorState(document: document);

      final selection = Selection.collapsed(
        Position(path: [0], offset: text1.length + text2.length + 1),
      );
      editorState.selection = selection;

      final result = await formatMarkdownLinkToLink.execute(editorState);

      expect(result, true);
      final after = editorState.getNodeAtPath([0])!;
      expect(after.delta!.toPlainText(), '$text1$text2');
      expect(after.delta!.toList()[0].attributes, null);
      expect(
        after.delta!.toList()[1].attributes,
        {AppFlowyRichTextKeys.href: link},
      );
    });

    // Before
    // AppFlowy[](|
    // After
    // AppFlowy[]()|
    test('empty text change nothing', () async {
      const text = 'AppFlowy[](';
      final document = Document.blank().addParagraphs(
        1,
        builder: (index) => Delta()..insert(text),
      );

      final editorState = EditorState(document: document);

      final selection = Selection.collapsed(
        Position(path: [0], offset: text.length),
      );
      editorState.selection = selection;

      final result = await formatTildeToStrikethrough.execute(editorState);

      expect(result, false);
      final after = editorState.getNodeAtPath([0])!;
      expect(after.delta!.toPlainText(), text);
    });
  });
}
