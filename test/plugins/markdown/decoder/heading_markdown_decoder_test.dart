import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helper.dart';

void main() async {
  group('markdown_heading_parser.dart', () {
    const parser = MarkdownHeadingParser();
    test('convert # to heading', () {
      final headingMarkdown = [
        '# Heading 1',
        '## Heading 2',
        '### Heading 3',
        '#### Heading 4',
        '##### Heading 5',
        '###### Heading 6',
      ];

      for (var i = 0; i < 6; i++) {
        final result = parser.parseMarkdown(headingMarkdown[i]);
        expect(result!.delta!.toPlainText(), 'Heading ${i + 1}');
        expect(result.attributes[HeadingBlockKeys.level], i + 1);
        expect(result.type, HeadingBlockKeys.type);
      }
    });

    test('if number of # > 7', () {
      final result = parser.parseMarkdown('####### Heading 7');
      expect(result, null);
    });

    test('if no #', () {
      final result = parser.parseMarkdown('Heading');
      expect(result, null);
    });

    test('if no space after #', () {
      final result = parser.parseMarkdown('#Heading');
      expect(result, null);
    });

    test('contains # but not at the beginning', () {
      final result = parser.parseMarkdown('Heading #');
      expect(result, null);
    });

    test('with another markdown syntaxes', () {
      final result = parser.parseMarkdown(
        '## 👋 **Welcome to** ***[AppFlowy Editor](appflowy.io)***',
      );
      expect(result!.toJson(), {
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
