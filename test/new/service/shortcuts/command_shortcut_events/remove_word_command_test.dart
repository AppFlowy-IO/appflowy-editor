import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../infra/testable_editor.dart';
import '../../../util/util.dart';

// single | means the cursor
// double | means the selection
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

  const text = 'Welcome to AppFlowy Editor 🔥!';

  group('remove word commands - widget test', () {
    group('remove the left word ', () {
      // Before
      // |Welcome to AppFlowy Editor 🔥!
      // After
      // |Welcome to AppFlowy Editor 🔥!
      testWidgets('at the start of line', (tester) async {
        final editor = tester.editor
          ..addParagraph(
            initialText: text,
          );
        await editor.startTesting();

        final selection = Selection.collapsed(Position(path: [0]));
        await editor.updateSelection(selection);

        await editor.pressKey(
          key: LogicalKeyboardKey.backspace,
          isAltPressed: Platform.isMacOS,
          isControlPressed: Platform.isWindows || Platform.isLinux,
        );
        await tester.pumpAndSettle();

        // the left word should be deleted.
        expect(
          editor.nodeAtPath([0])?.delta?.toPlainText(),
          text,
        );

        await editor.dispose();
      });

      // Before
      // Welcome| to AppFlowy Editor 🔥!
      // After
      // | to AppFlowy Editor 🔥!
      testWidgets('at the end of a word', (tester) async {
        final editor = tester.editor
          ..addParagraph(
            initialText: text,
          );
        await editor.startTesting();

        // Welcome| to AppFlowy Editor 🔥!
        const welcome = 'Welcome';
        final selection =
            Selection.collapsed(Position(path: [0], offset: welcome.length));
        await editor.updateSelection(selection);

        await editor.pressKey(
          key: LogicalKeyboardKey.backspace,
          isAltPressed: Platform.isMacOS,
          isControlPressed: Platform.isWindows || Platform.isLinux,
        );
        await tester.pumpAndSettle();

        // the left word should be deleted.
        expect(
          editor.nodeAtPath([0])?.delta?.toPlainText(),
          text.substring(welcome.length),
        );

        await editor.dispose();
      });

      // Before
      // Welcome |to AppFlowy Editor 🔥!
      // After
      // |to AppFlowy Editor 🔥!
      testWidgets('at the end of a word and whitespace', (tester) async {
        final editor = tester.editor
          ..addParagraph(
            initialText: text,
          );
        await editor.startTesting();

        // Welcome| to AppFlowy Editor 🔥!
        const welcome = 'Welcome';
        final selection = Selection.collapsed(
          Position(path: [0], offset: welcome.length + 1),
        );
        await editor.updateSelection(selection);

        await editor.pressKey(
          key: LogicalKeyboardKey.backspace,
          isAltPressed: Platform.isMacOS,
          isControlPressed: Platform.isWindows || Platform.isLinux,
        );
        await tester.pumpAndSettle();

        // the left word should be deleted.
        expect(
          editor.nodeAtPath([0])?.delta?.toPlainText(),
          text.substring(welcome.length + 1),
        );

        await editor.dispose();
      });
    });

    group('remove the right word ', () {
      // Before
      // Welcome to AppFlowy Editor 🔥!|
      // After
      // Welcome to AppFlowy Editor 🔥!|
      testWidgets('at the end of line', (tester) async {
        final editor = tester.editor
          ..addParagraph(
            initialText: text,
          );
        await editor.startTesting();

        final selection =
            Selection.collapsed(Position(path: [0], offset: text.length));
        await editor.updateSelection(selection);

        await editor.pressKey(
          key: LogicalKeyboardKey.delete,
          isAltPressed: Platform.isMacOS,
          isControlPressed: Platform.isWindows || Platform.isLinux,
        );
        await tester.pumpAndSettle();

        // nothing happens
        expect(
          editor.nodeAtPath([0])?.delta?.toPlainText(),
          text,
        );

        await editor.dispose();
      });

      // Before
      // |Welcome to AppFlowy Editor 🔥!
      // After
      // | to AppFlowy Editor 🔥!
      testWidgets('at the start of a word', (tester) async {
        final editor = tester.editor
          ..addParagraph(
            initialText: text,
          );
        await editor.startTesting();

        // |Welcome to AppFlowy Editor 🔥!
        const welcome = 'Welcome';
        final selection = Selection.collapsed(Position(path: [0]));
        await editor.updateSelection(selection);

        await editor.pressKey(
          key: LogicalKeyboardKey.delete,
          isAltPressed: Platform.isMacOS,
          isControlPressed: Platform.isWindows || Platform.isLinux,
        );
        await tester.pumpAndSettle();

        // the right word should be deleted.
        expect(
          editor.nodeAtPath([0])?.delta?.toPlainText(),
          text.substring(welcome.length),
        );

        await editor.dispose();
      });

      // Before
      // Welcome| to AppFlowy Editor 🔥!
      // After
      // Welcome| AppFlowy Editor 🔥!
      testWidgets('at the end of a word and whitespace', (tester) async {
        final editor = tester.editor
          ..addParagraph(
            initialText: text,
          );
        await editor.startTesting();

        // Welcome| to AppFlowy Editor 🔥!
        const welcome = 'Welcome';
        final selection =
            Selection.collapsed(Position(path: [0], offset: welcome.length));
        await editor.updateSelection(selection);

        await editor.pressKey(
          key: LogicalKeyboardKey.delete,
          isAltPressed: Platform.isMacOS,
          isControlPressed: Platform.isWindows || Platform.isLinux,
        );
        await tester.pumpAndSettle();

        // the right word should be deleted.
        const expectedString = "Welcome AppFlowy Editor 🔥!";
        expect(
          editor.nodeAtPath([0])?.delta?.toPlainText(),
          expectedString,
        );

        await editor.dispose();
      });
    });
  });
}
