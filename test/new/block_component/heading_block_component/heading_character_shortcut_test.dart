import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../util/util.dart';
import '../test_character_shortcut.dart';

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

  group('formate', () {
    const text = 'Welcome to AppFlowy Editor 🔥!';

    // Before
    // ''
    // After
    // ' '
    test('mock inputting a ` ` after the >', () async {
      testFormatCharacterShortcut(formatSignToHeading, '', 0,
          (result, before, after) {
        expect(result, false);
        expect(before.delta!.toPlainText(), '');
        expect(after.delta!.toPlainText(), '');
        expect(after.type != HeadingBlockKeys.type, true);
      }, text: '');
    });

    // Before
    // #|Welcome to AppFlowy Editor 🔥!
    // After
    // [heading] Welcome to AppFlowy Editor 🔥!
    test('mock inputting a ` ` after the #', () async {
      for (var i = 1; i <= 6; i++) {
        testFormatCharacterShortcut(
          formatSignToHeading,
          '#' * i,
          i,
          (result, before, after) {
            expect(result, true);
            expect(after.delta!.toPlainText(), text);
            expect(after.type, 'heading');
          },
          text: text,
        );
      }
    });

    // Before
    // #######|Welcome to AppFlowy Editor 🔥!
    // After
    // #######|Welcome to AppFlowy Editor 🔥!
    test('mock inputting a ` ` after the #', () async {
      testFormatCharacterShortcut(
        formatSignToHeading,
        '#' * 7,
        7,
        (result, before, after) {
          // nothing happens
          expect(result, false);
          expect(before.toJson(), after.toJson());
        },
        text: text,
      );
    });

    // Before
    // >W|elcome to AppFlowy Editor 🔥!
    // After
    // >W|elcome to AppFlowy Editor 🔥!
    test('mock inputting a ` ` in the middle of the node', () async {
      testFormatCharacterShortcut(
        formatSignToHeading,
        '#',
        2,
        (result, before, after) {
          // nothing happens
          expect(result, false);
          expect(before.toJson(), after.toJson());
        },
        text: text,
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
  });
}
