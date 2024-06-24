import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  test('word count regex test', () {
    final testCases = [
      ('Hello world', 2),
      ('Hello', 1),
      ('', 0),
      ('Hello, world!', 2),
      ('1234 is a number', 4),
      ('Hello@world#today', 3),
      ('Hello   world', 2),
      ('Hello\nworld', 2),
      ('It\'s a lovely day, isn\'t it? 123! Go.', 10),
      ('High-speed rail networks are fast.', 6),
      ('Hello 你好 こんにちは 안녕하세요', 4),
    ];

    for (final testCase in testCases) {
      final text = testCase.$1;
      final expectedWordCount = testCase.$2;

      final wordMatches = appFlowyEditorWordRegex.allMatches(text);
      final wordCount = wordMatches.length;

      expect(wordCount, expectedWordCount);
    }
  });
}
