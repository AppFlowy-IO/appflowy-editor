import 'package:appflowy_editor/src/plugins/markdown/decoder/document_markdown_decoder.dart';
import 'package:appflowy_editor/src/plugins/markdown/decoder/parser/markdown_block_quote_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('markdown_quote_list_parser.dart', () {
    final parser = DocumentMarkdownDecoder(
      markdownElementParsers: [
        const MarkdownBlockQuoteParserV2(),
      ],
    );

    test('convert > to quote ', () {
      final result = parser.convert('> Quote 1');
      expect(result.root.children[0].toJson(), {
        'type': 'quote',
        'data': {
          'delta': [
            {'insert': 'Quote 1'},
          ],
        },
      });
    });

    test('if no >', () {
      final result = parser.convert('Quote 1');
      expect(result.root.children.isEmpty, true);
    });

    test('if no space after >', () {
      final result = parser.convert('Quote 1');
      expect(result.root.children.isEmpty, true);
    });
  });
}
