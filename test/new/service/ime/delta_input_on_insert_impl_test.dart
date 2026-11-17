import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
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
    // fcitx5 on Linux reports the selection at the start of the preedit while
    // the composing range spans the whole preedit. The second character has to
    // be appended to the preedit, not prepended to it.
    testWidgets('appends composing text at the reported insertion offset',
        (tester) async {
      final editor = tester.editor..addEmptyParagraph();
      await editor.startTesting();
      await editor.updateSelection(Selection.collapsed(Position(path: [0])));

      final imeInput = editor.ime.imeInput;
      // preedit "这":  text = " 这", composing = [1, 2], caret at 1
      await imeInput.apply([
        const TextEditingDeltaInsertion(
          oldText: ' ',
          textInserted: '这',
          insertionOffset: 1,
          selection: TextSelection.collapsed(offset: 1),
          composing: TextRange(start: 1, end: 2),
        ),
      ]);
      await tester.pumpAndSettle();
      expect(editor.nodeAtPath([0])!.delta!.toPlainText(), '这');

      // preedit "这是": text = " 这是", composing = [1, 3], caret still at 1
      await imeInput.apply([
        const TextEditingDeltaInsertion(
          oldText: ' 这',
          textInserted: '是',
          insertionOffset: 2,
          selection: TextSelection.collapsed(offset: 1),
          composing: TextRange(start: 1, end: 3),
        ),
      ]);
      await tester.pumpAndSettle();

      expect(editor.nodeAtPath([0])!.delta!.toPlainText(), '这是');
      await editor.dispose();
    });
  });
}
