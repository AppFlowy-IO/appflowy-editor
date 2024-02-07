import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../new/infra/testable_editor.dart';

void main() async {
  late final WordCountService service;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  tearDown(() {
    service.dispose();
  });

  group('word_counter_service.dart', () {
    testWidgets(
      'Word and Character count updates',
      (tester) async {
        const text = 'Welcome to Appflowy!';
        final editor = tester.editor..addParagraphs(3, initialText: text);
        await editor.startTesting();

        service = WordCountService(editorState: editor.editorState)..register();

        expect(service.wordCount, 3 * 3); // 9 Words
        expect(service.charCount, text.length * 3);

        int wordCount = 0;
        int charCount = 0;

        void setCounters() {
          wordCount = service.wordCount;
          charCount = service.charCount;
        }

        service.addListener(setCounters);

        final transaction = editor.editorState.transaction
          ..insertText(
            editor.editorState.getNodeAtPath([0])!,
            text.length,
            text,
          );

        await editor.editorState.apply(transaction);

        await tester.pumpAndSettle();

        expect(service.wordCount, 3 * 4);
        expect(service.charCount, text.length * 4);
        expect(wordCount, 3 * 4);
        expect(charCount, text.length * 4);

        service.stop();

        expect(service.wordCount, 0);
        expect(service.charCount, 0);
        expect(wordCount, 0);
        expect(charCount, 0);

        service.removeListener(setCounters);
      },
    );
  });
}
