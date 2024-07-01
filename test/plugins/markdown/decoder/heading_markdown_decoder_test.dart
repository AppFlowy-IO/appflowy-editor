import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/plugins/markdown/decoder/parser/markdown_heading_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('markdown_heading_parser.dart', () {
    test('convert # to heading', () {
      final headingMarkdown = [
        '# Heading 1',
        '## Heading 2',
        '### Heading 3',
        '#### Heading 4',
        '##### Heading 5',
        '###### Heading 6',
      ];

      const parser = MarkdownHeadingParser();

      for (var i = 0; i < 6; i++) {
        final decoder = DeltaMarkdownDecoder();
        final result = parser.transform(decoder, headingMarkdown[i]);
        expect(result!.delta!.toPlainText(), 'Heading ${i + 1}');
        expect(result.attributes[HeadingBlockKeys.level], i + 1);
      }
    });

    test('if number of # > 7', () {
      const parser = MarkdownHeadingParser();
      final decoder = DeltaMarkdownDecoder();
      final result = parser.transform(decoder, '####### Heading 7');
      expect(result, null);
    });

    test('if no #', () {
      const parser = MarkdownHeadingParser();
      final decoder = DeltaMarkdownDecoder();
      final result = parser.transform(decoder, 'Heading');
      expect(result, null);
    });

    test('if no space after #', () {
      const parser = MarkdownHeadingParser();
      final decoder = DeltaMarkdownDecoder();
      final result = parser.transform(decoder, '#Heading');
      expect(result, null);
    });
  });
}
