import 'package:flutter_test/flutter_test.dart';

import 'package:appflowy_editor/appflowy_editor.dart';

import '../../new/infra/testable_editor.dart';

void main() async {
  late WordCountService service;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  tearDownAll(() {
    service.dispose();
  });

  group('word_counter_service.dart', () {
    testWidgets('Word and Character count updates', (tester) async {
      const text = 'Welcome to Appflowy!';
      final editor = tester.editor..addParagraphs(3, initialText: text);
      await editor.startTesting();

      service = WordCountService(editorState: editor.editorState)..register();

      expect(service.documentCounters.wordCount, 3 * 3); // 9 Words
      expect(service.documentCounters.charCount, text.length * 3);

      int wordCount = 0;
      int charCount = 0;

      void setCounters() {
        wordCount = service.documentCounters.wordCount;
        charCount = service.documentCounters.charCount;
      }

      service.addListener(setCounters);

      final transaction = editor.editorState.transaction
        ..insertText(
          editor.editorState.getNodeAtPath([0])!,
          text.length,
          text,
        );

      await editor.editorState.apply(transaction);

      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      expect(service.documentCounters.wordCount, 3 * 4);
      expect(service.documentCounters.charCount, text.length * 4);
      expect(wordCount, 3 * 4);
      expect(charCount, text.length * 4);

      service.stop();

      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      expect(service.documentCounters.wordCount, 0);
      expect(service.documentCounters.charCount, 0);
      expect(wordCount, 0);
      expect(charCount, 0);

      service.removeListener(setCounters);
    });

    testWidgets('Selection Word and Character count updates', (tester) async {
      const text = 'Welcome to Appflowy!';
      final editor = tester.editor..addParagraphs(3, initialText: text);
      await editor.startTesting();

      service = WordCountService(editorState: editor.editorState)..register();

      expect(service.selectionCounters.wordCount, 0);
      expect(service.selectionCounters.charCount, 0);

      int wordCount = 0;
      int charCount = 0;

      void setCounters() {
        wordCount = service.selectionCounters.wordCount;
        charCount = service.selectionCounters.charCount;
      }

      service.addListener(setCounters);

      await editor.updateSelection(
        Selection(
          start: Position(path: [0]),
          end: Position(path: [0], offset: text.length),
        ),
      );
      await tester.pumpAndSettle();

      expect(service.selectionCounters.wordCount, 3);
      expect(service.selectionCounters.charCount, text.length);
      expect(wordCount, 3);
      expect(charCount, text.length);

      service.stop();

      expect(service.selectionCounters.wordCount, 0);
      expect(service.selectionCounters.charCount, 0);
      expect(wordCount, 0);
      expect(charCount, 0);

      service.removeListener(setCounters);
    });

    testWidgets('Selection Word and Character count on-demand', (tester) async {
      const text = 'Welcome to Appflowy!';
      final editor = tester.editor..addParagraphs(3, initialText: text);
      await editor.startTesting();

      service = WordCountService(editorState: editor.editorState);

      expect(service.documentCounters.wordCount, 0);
      expect(service.documentCounters.charCount, 0);
      expect(service.selectionCounters.wordCount, 0);
      expect(service.selectionCounters.charCount, 0);

      await editor.updateSelection(
        Selection(
          start: Position(path: [0]),
          end: Position(path: [0], offset: text.length),
        ),
      );
      await tester.pumpAndSettle();

      expect(service.selectionCounters.wordCount, 0);
      expect(service.selectionCounters.charCount, 0);

      final odDocCounters = service.getDocumentCounters();
      expect(odDocCounters.wordCount, 3 * 3);
      expect(odDocCounters.charCount, text.length * 3);

      final odSelectionCounters = service.getSelectionCounters();
      expect(odSelectionCounters.wordCount, 3);
      expect(odSelectionCounters.charCount, text.length);
    });
  });
}
