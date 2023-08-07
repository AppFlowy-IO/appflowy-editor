import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../infra/testable_editor.dart';

void main() async {
  group('numbered list component', () {
    const text = 'Welcome to AppFlowy Editor 🔥!';
    // 100. Welcome to AppFlowy Editor 🔥!
    // 101. Welcome to AppFlowy Editor 🔥!
    // 102. Welcome to AppFlowy Editor 🔥!
    testWidgets('the number of the numbered list should be ascending',
        (tester) async {
      final editor = tester.editor
        ..addNode(
          numberedListNode(delta: Delta()..insert(text), number: 100),
        )
        ..addNode(
          numberedListNode(delta: Delta()..insert(text)),
        )
        ..addNode(
          numberedListNode(delta: Delta()..insert(text), number: 200),
        );
      await editor.startTesting();

      expect(find.text('100.', findRichText: true), findsOneWidget);
      expect(find.text('101.', findRichText: true), findsOneWidget);
      expect(find.text('102.', findRichText: true), findsOneWidget);
      expect(find.text('200.', findRichText: true), findsNothing);

      await editor.dispose();
    });

    // Before
    // | <- insert new numbered list here
    // 100. Welcome to AppFlowy Editor 🔥!
    // 101. Welcome to AppFlowy Editor 🔥!
    // After
    // 1. Welcome to AppFlowy Editor 🔥!
    // 2. Welcome to AppFlowy Editor 🔥!
    // 3. Welcome to AppFlowy Editor 🔥!
    testWidgets(
        'insert a new numbered list before the existing one, and the number should keep ascending',
        (tester) async {
      final editor = tester.editor
        ..addParagraph(initialText: text)
        ..addNode(
          numberedListNode(delta: Delta()..insert(text), number: 100),
        )
        ..addNode(
          numberedListNode(delta: Delta()..insert(text)),
        );
      await editor.startTesting();

      expect(find.text('100.', findRichText: true), findsOneWidget);
      expect(find.text('101.', findRichText: true), findsOneWidget);

      final selection = Selection.collapsed(Position(path: [0]));
      await editor.updateSelection(selection);

      await editor.ime.typeText('1.');
      await editor.ime.typeText(' ');

      expect(editor.nodeAtPath([0])!.type, NumberedListBlockKeys.type);
      expect(find.text('1.', findRichText: true), findsOneWidget);
      expect(find.text('2.', findRichText: true), findsOneWidget);
      expect(find.text('3.', findRichText: true), findsOneWidget);
      expect(find.text('100.', findRichText: true), findsNothing);
      expect(find.text('101.', findRichText: true), findsNothing);

      await editor.dispose();
    });

    // Before
    // 1. Welcome to AppFlowy Editor 🔥!
    // | <- delete this line
    // 100. Welcome to AppFlowy Editor 🔥!
    // 101. Welcome to AppFlowy Editor 🔥!
    // After
    // 1. Welcome to AppFlowy Editor 🔥!
    // 2. Welcome to AppFlowy Editor 🔥!
    // 3. Welcome to AppFlowy Editor 🔥!
    testWidgets(
        'delete the paragraph between two group of numbered lists, and the number of the following numbered list should keep ascending',
        (tester) async {
      final editor = tester.editor
        ..addNode(
          numberedListNode(delta: Delta()..insert(text), number: 1),
        )
        ..addEmptyParagraph()
        ..addNode(
          numberedListNode(delta: Delta()..insert(text), number: 100),
        )
        ..addNode(
          numberedListNode(delta: Delta()..insert(text)),
        );
      await editor.startTesting();

      expect(find.text('1.', findRichText: true), findsOneWidget);
      expect(find.text('100.', findRichText: true), findsOneWidget);
      expect(find.text('101.', findRichText: true), findsOneWidget);

      final selection = Selection.collapsed(Position(path: [1]));
      await editor.updateSelection(selection);

      await editor.pressKey(key: LogicalKeyboardKey.backspace);

      expect(editor.documentRootLen, 3);
      expect(find.text('1.', findRichText: true), findsOneWidget);
      expect(find.text('2.', findRichText: true), findsOneWidget);
      expect(find.text('3.', findRichText: true), findsOneWidget);
      expect(find.text('100.', findRichText: true), findsNothing);
      expect(find.text('101.', findRichText: true), findsNothing);

      await editor.ime.typeText('\n');
      await editor.ime.typeText('\n');
      expect(editor.documentRootLen, 4);
      expect(find.text('1.', findRichText: true), findsOneWidget);
      expect(find.text('2.', findRichText: true), findsNothing);
      expect(find.text('3.', findRichText: true), findsNothing);
      expect(find.text('100.', findRichText: true), findsOneWidget);
      expect(find.text('101.', findRichText: true), findsOneWidget);

      await editor.dispose();
    });
  });
}
