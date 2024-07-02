import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helper.dart';

void main() async {
  group('markdown_quote_list_parser.dart', () {
    test('convert > to quote ', () {
      const markdown = '> Quote 1';
      const parser = MarkdownQuoteListParser();
      final result = parser.parseMarkdown(markdown);
      expect(result!.type, QuoteBlockKeys.type);
      expect(result.delta!.toPlainText(), 'Quote 1');
    });

    test('if no >', () {
      const markdown = 'Quote 1';
      const parser = MarkdownQuoteListParser();
      final result = parser.parseMarkdown(markdown);
      expect(result, null);
    });

    test('if no space after >', () {
      const markdown = '>Quote 1';
      const parser = MarkdownQuoteListParser();
      final result = parser.parseMarkdown(markdown);
      expect(result, null);
    });
  });
}
