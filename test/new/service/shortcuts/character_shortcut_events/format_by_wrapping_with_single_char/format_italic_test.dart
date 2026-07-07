import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../util/util.dart';

void main() async {
  group('format italic', () {
    group('by wrapping with single underscore', () {
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
      // After (unchanged): the opening underscore is not preceded by
      // whitespace, so an intra-word underscore like `a_b_` is not italicized.
      test('App_Flowy_ does not italicize (intra-word underscore)', () async {
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

        expect(result, false);
        final after = editorState.getNodeAtPath([0])!;
        expect(after.delta!.toPlainText(), '${text1}_$text2');
        final isItalic = after.delta!
            .everyAttributes((element) => element['italic'] == true);
        expect(isItalic, false);
      });

      // Before
      // hi _AppFlowy|
      // After
      // hi [italic]AppFlowy
      // The opening underscore is preceded by whitespace, so it still formats.
      test('hi _AppFlowy_ italicizes AppFlowy (underscore after space)',
          () async {
        const prefix = 'hi ';
        const text = 'AppFlowy';
        final document = Document.blank().addParagraphs(
          1,
          builder: (index) => Delta()..insert('${prefix}_$text'),
        );

        final editorState = EditorState(document: document);

        final selection = Selection.collapsed(
          Position(path: [0], offset: prefix.length + text.length + 1),
        );
        editorState.selection = selection;

        final result = await formatUnderscoreToItalic.execute(editorState);

        expect(result, true);
        final after = editorState.getNodeAtPath([0])!;
        expect(after.delta!.toPlainText(), '$prefix$text');
        final deltaList = after.delta!.toList();
        expect(deltaList[0].attributes, null);
        expect(deltaList[1].attributes, {'italic': true});
      });

      // Before
      // AppFlowy_|
      // After
      // AppFlowy__| (last underscore used to trigger the formatUnderscoreToItalic)
      test('__double underscore change nothing', () async {
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

    group('by wrapping with single asterisk', () {
      // Before
      // *AppFlowy|
      // After
      // [italic]AppFlowy
      test('*AppFlowy* to italic AppFlowy', () async {
        const text = 'AppFlowy';
        final document = Document.blank().addParagraphs(
          1,
          builder: (index) => Delta()..insert('*$text'),
        );

        final editorState = EditorState(document: document);

        // add cursor in the end of the text
        final selection = Selection.collapsed(
          Position(path: [0], offset: text.length + 1),
        );
        editorState.selection = selection;
        // run targeted CharacterShortcutEvent
        final result = await formatAsteriskToItalic.execute(editorState);

        expect(result, true);
        final after = editorState.getNodeAtPath([0])!;
        expect(after.delta!.toPlainText(), text);
        expect(after.delta!.toList()[0].attributes, {'italic': true});
      });

      // Before
      // App*Flowy|
      // After
      // App[italic]Flowy
      test('App*Flowy* to App[italic]Flowy', () async {
        const text1 = 'App';
        const text2 = 'Flowy';
        final document = Document.blank().addParagraphs(
          1,
          builder: (index) => Delta()..insert('$text1*$text2'),
        );

        final editorState = EditorState(document: document);

        final selection = Selection.collapsed(
          Position(path: [0], offset: text1.length + text2.length + 1),
        );
        editorState.selection = selection;

        final result = await formatAsteriskToItalic.execute(editorState);

        expect(result, true);
        final after = editorState.getNodeAtPath([0])!;
        final afterDelta = after.delta!;
        expect(afterDelta.toPlainText(), '$text1$text2');
        final deltaList = afterDelta.toList();
        expect(deltaList.length, 2);
        expect(deltaList[0].attributes, null);
        expect(deltaList[1].attributes, {'italic': true});
      });

      // Before
      // AppFlowy*|
      // After
      // AppFlowy**| (last asterisk used to trigger the formatAsteriskToItalic)
      test('**doule asterisk change nothing', () async {
        const text = 'AppFlowy*';
        final document = Document.blank().addParagraphs(
          1,
          builder: (index) => Delta()..insert(text),
        );

        final editorState = EditorState(document: document);

        final selection = Selection.collapsed(
          Position(path: [0], offset: text.length),
        );
        editorState.selection = selection;

        final result = await formatAsteriskToItalic.execute(editorState);

        expect(result, false);
        final after = editorState.getNodeAtPath([0])!;
        expect(after.delta!.toPlainText(), text);
      });
    });

    // Before
    // <italic>_AppFlowy</italic>
    // After
    // AppFlowy
    test('remove the format', () async {
      const text = '_AppFlowy';
      final document = Document.blank().addParagraphs(
        1,
        builder: (index) => Delta()
          ..insert(
            text,
            attributes: {
              'italic': true,
            },
          ),
      );

      final editorState = EditorState(document: document);

      final selection = Selection.collapsed(
        Position(path: [0], offset: text.length),
      );
      editorState.selection = selection;

      final result = await formatUnderscoreToItalic.execute(editorState);

      expect(result, true);
      final after = editorState.getNodeAtPath([0])!;
      expect(
        after.delta!.toPlainText(),
        text.substring(1),
      ); // remove the first underscore
      final isItalic =
          after.delta!.everyAttributes((element) => element['italic'] == true);
      expect(
        isItalic,
        false,
      );
    });

    // skip the italic when the text is wrapped with code
    // Before
    // `App_Flowy|`
    // After
    // `App_Flowy_`
    test('skip the italic when the text is wrapped with code', () async {
      const text = 'App_Flowy';
      final document = Document.blank().addParagraphs(
        1,
        builder: (index) => Delta()
          ..insert(
            text,
            attributes: {
              AppFlowyRichTextKeys.code: true,
            },
          ),
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
      final isItalic = after.delta!.any(
        (element) => element.attributes?[AppFlowyRichTextKeys.italic] == true,
      );
      expect(isItalic, false);
    });
  });
}
