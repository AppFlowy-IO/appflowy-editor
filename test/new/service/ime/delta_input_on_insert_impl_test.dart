import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../infra/testable_editor.dart';

void main() async {
  group('delta input insert - widget test', () {
    const text = 'Welcome to AppFlowy Editor 🔥!';

    // Before
    // |Welcome| to AppFlowy Editor 🔥!
    // After
    // |a| to AppFlowy Editor 🔥!
    testWidgets('replace a text in non-collapsed selection', (tester) async {
      final editor = tester.editor
        ..addParagraph(
          initialText: text,
        );
      await editor.startTesting();

      final selection = Selection.single(
        path: [0],
        startOffset: 0,
        endOffset: 'Welcome'.length,
      );
      await editor.updateSelection(selection);
      await editor.ime.typeText('a');

      expect(
        editor.selection,
        Selection.collapsed(Position(path: [0], offset: 1)),
      );
      expect(
        editor.nodeAtPath([0])!.delta!.toPlainText(),
        'a to AppFlowy Editor 🔥!',
      );

      await editor.dispose();
    });

    // Before
    // Welcome| to AppFlowy Editor 🔥!
    // Welcome to AppFlowy Editor 🔥!
    // Welcome| to AppFlowy Editor 🔥!
    // After
    // Welcomea to AppFlowy Editor 🔥!
    testWidgets('replace a text in multi-line selection', (tester) async {
      final editor = tester.editor
        ..addParagraphs(
          3,
          initialText: text,
        );
      await editor.startTesting();

      const welcomeLength = 'Welcome'.length;
      final selection = Selection(
        start: Position(path: [0], offset: welcomeLength),
        end: Position(path: [2], offset: welcomeLength),
      );
      await editor.updateSelection(selection);

      await editor.ime.typeText('a');

      expect(
        editor.selection,
        Selection.collapsed(Position(path: [0], offset: welcomeLength + 1)),
      );
      expect(
        editor.nodeAtPath([0])!.delta!.toPlainText(),
        'Welcomea to AppFlowy Editor 🔥!',
      );

      await editor.dispose();
    });
  });
}
