import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../infra/testable_editor.dart';

void main() async {
  group('backslash to igore character shortcut', () {
    group('For the wrapped style shortcut events', () {
      testWidgets('_AppFlowy[backslash]_ to _AppFlowy_', (tester) async {
        const originalText = '_AppFlowy\\';
        const resultText = '_AppFlowy_';

        final editor = tester.editor..addParagraph(initialText: originalText);
        await editor.startTesting();

        await editor.updateSelection(
          Selection.collapsed(Position(path: [0], offset: originalText.length)),
        );

        await editor.ime.typeText('_');

        final node = editor.nodeAtPath([0]);
        expect(node!.delta!.toList()[0].attributes, null);
        expect(node.delta!.toPlainText(), resultText);
        await editor.dispose();
      });

      testWidgets('__AppFlowy_[backslash]_ to __AppFlowy__', (tester) async {
        const originalText = '__AppFlowy_\\';
        const resultText = '__AppFlowy__';

        final editor = tester.editor..addParagraph(initialText: originalText);
        await editor.startTesting();

        await editor.updateSelection(
          Selection.collapsed(Position(path: [0], offset: originalText.length)),
        );

        await editor.ime.typeText('_');

        final node = editor.nodeAtPath([0]);
        expect(node!.delta!.toList()[0].attributes, null);
        expect(node.delta!.toPlainText(), resultText);

        await editor.dispose();
      });

// Even the previous text has ignored the character shortcut by back slash
// The rest of the text should still can be formatted by character shortcut later
// The following '_Hello_' has been ignored the character shortcut by back slash
      testWidgets('_Hello_ _AppFlowy_ to _Hello_ AppFlowy[italic]',
          (tester) async {
        const originalText = '_Hello_ _AppFlowy';
        const resultText = '_Hello_ AppFlowy';

        final editor = tester.editor..addParagraph(initialText: originalText);
        await editor.startTesting();

        await editor.updateSelection(
          Selection.collapsed(Position(path: [0], offset: originalText.length)),
        );

        await editor.ime.typeText('_');

        final node = editor.nodeAtPath([0]);
        expect(node!.delta!.toList()[0].attributes, null);
        expect(node.delta!.toList()[1].attributes, {'italic': true});
        expect(node.delta!.toPlainText(), resultText);

        await editor.dispose();
      });

      testWidgets('`AppFlowy[backslash]` to `AppFlowy` ', (tester) async {
        const originalText = '`AppFlowy\\';
        const resultText = '`AppFlowy`';

        final editor = tester.editor..addParagraph(initialText: originalText);
        await editor.startTesting();

        await editor.updateSelection(
          Selection.collapsed(Position(path: [0], offset: originalText.length)),
        );

        await editor.ime.typeText('`');

        final node = editor.nodeAtPath([0]);
        expect(node!.delta!.toList()[0].attributes, null);
        expect(node.delta!.toPlainText(), resultText);

        await editor.dispose();
      });
    });

    group('For the space enabled shortcut events', () {
      testWidgets('[backslash]- to - ', (tester) async {
        const originalText = '\\-';
        const resultText = '- ';

        final editor = tester.editor..addParagraph(initialText: originalText);
        await editor.startTesting();

        await editor.updateSelection(
          Selection.collapsed(Position(path: [0], offset: originalText.length)),
        );

        await editor.ime.typeText(' ');

        final node = editor.nodeAtPath([0]);
        expect(node!.delta!.toList()[0].attributes, null);
        expect(node.delta!.toPlainText(), resultText);

        await editor.dispose();
      });

      testWidgets('[{backslash}] to [] ', (tester) async {
        const originalText = '[\\]';
        const resultText = '[] ';

        final editor = tester.editor..addParagraph(initialText: originalText);
        await editor.startTesting();

        await editor.updateSelection(
          Selection.collapsed(Position(path: [0], offset: originalText.length)),
        );

        await editor.ime.typeText(' ');

        final node = editor.nodeAtPath([0]);
        expect(node!.delta!.toList()[0].attributes, null);
        expect(node.delta!.toPlainText(), resultText);

        await editor.dispose();
      });
    });
  });
}
