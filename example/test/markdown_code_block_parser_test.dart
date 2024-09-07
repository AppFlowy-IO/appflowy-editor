import 'package:appflowy_editor/src/plugins/markdown/decoder/document_markdown_decoder.dart';
import 'package:example/pages/markdown/markdown_code_block_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('markdown_heading_parser.dart', () {
    final parser = DocumentMarkdownDecoder(
      markdownElementParsers: [
        const MarkdownCodeBlockParserV2(),
      ],
    );

    test('contains quote syntax', () {
      const codeBlockMarkdown = '''```python
# Example of using the GTD class
gtd_system = GTD()
gtd_system.capture("Write a blog post")
gtd_system.capture("Prepare presentation for Monday")
gtd_system.capture("Plan vacation")
gtd_system.clarify()
gtd_system.review()
gtd_system.engage()
```''';

      final result = parser.convert(codeBlockMarkdown);
      final codeBlock = result.root.children.first;
      expect(codeBlock.toJson(), {
        'type': 'code',
        'data': {
          'language': 'python',
          'delta': [
            {
              'insert': '''# Example of using the GTD class
gtd_system = GTD()
gtd_system.capture("Write a blog post")
gtd_system.capture("Prepare presentation for Monday")
gtd_system.capture("Plan vacation")
gtd_system.clarify()
gtd_system.review()
gtd_system.engage()''',
            },
          ],
        },
      });
    });
  });
}
