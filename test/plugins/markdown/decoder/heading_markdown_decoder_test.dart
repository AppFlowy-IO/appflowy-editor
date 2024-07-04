import 'package:appflowy_editor/src/plugins/markdown/decoder/document_markdown_decoder.dart';
import 'package:appflowy_editor/src/plugins/markdown/decoder/parser/markdown_heading_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('markdown_heading_parser.dart', () {
    final parser = DocumentMarkdownDecoder(
      markdownElementParsers: [
        const MarkdownHeadingParserV2(),
      ],
    );

    test('convert # to heading', () {
      const headingMarkdown = '''# Heading 1
## Heading 2
### Heading 3
#### Heading 4
##### Heading 5
###### Heading 6
      ''';

      final result = parser.convert(headingMarkdown);
      for (var i = 0; i < 6; i++) {
        expect(result.nodeAtPath([i])!.toJson(), {
          'type': 'heading',
          'data': {
            'level': i + 1,
            'delta': [
              {'insert': 'Heading ${i + 1}'},
            ],
          },
        });
      }
    });

    test('if number of # > 7', () {
      final result = parser.convert('####### Heading 7');
      expect(result.root.children.isEmpty, true);
    });

    test('if no #', () {
      final result = parser.convert('Heading');
      expect(result.root.children.isEmpty, true);
    });

    test('if no space after #', () {
      final result = parser.convert('#Heading');
      expect(result.root.children.isEmpty, true);
    });

    test('contains # but not at the beginning', () {
      final result = parser.convert('Heading #');
      expect(result.root.children.isEmpty, true);
    });

    test('with another markdown syntaxes', () {
      final result = parser.convert(
        '## 👋 **Welcome to** ***[AppFlowy Editor](appflowy.io)***',
      );
      expect(result.root.children[0].toJson(), {
        'type': 'heading',
        'data': {
          'level': 2,
          'delta': [
            {'insert': '👋 '},
            {
              'insert': 'Welcome to',
              'attributes': {'bold': true},
            },
            {'insert': ' '},
            {
              'insert': 'AppFlowy Editor',
              'attributes': {
                'italic': true,
                'bold': true,
                'href': 'appflowy.io',
              },
            }
          ],
        },
      });
    });
  });
}
