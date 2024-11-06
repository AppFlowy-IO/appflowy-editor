import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('ordered list decoder', () {
    final parser = DocumentMarkdownDecoder(
      markdownElementParsers: [
        const MarkdownUnorderedListItemParserV2(),
        const MarkdownUnorderedListParserV2(),
      ],
    );

    test('convert unordered list', () {
      final result = parser.convert('''
- Item 1
- Item 2
- Item 3
''');
      for (var i = 0; i < result.root.children.length; i++) {
        expect(result.root.children[i].toJson(), {
          'type': 'bulleted_list',
          'data': {
            'delta': [
              {'insert': 'Item ${i + 1}'},
            ],
          },
        });
      }
    });

    test('convert unordered list with nested list', () {
      final result = parser.convert('''
- Item 1
    - Item 1.1
    - Item 1.2
- Item 2
''');
      expect(result.root.children[0].toJson(), {
        'type': 'bulleted_list',
        'data': {
          'delta': [
            {'insert': 'Item 1'},
          ],
        },
        'children': [
          {
            'type': 'bulleted_list',
            'data': {
              'delta': [
                {'insert': 'Item 1.1'},
              ],
            },
          },
          {
            'type': 'bulleted_list',
            'data': {
              'delta': [
                {'insert': 'Item 1.2'},
              ],
            },
          },
        ],
      });
      expect(result.root.children[1].toJson(), {
        'type': 'bulleted_list',
        'data': {
          'delta': [
            {'insert': 'Item 2'},
          ],
        },
      });
    });

    test('if no - or *', () {
      final result = parser.convert('AppFlowy');
      expect(result.root.children.isEmpty, true);
    });

    test('if no space after -', () {
      final result = parser.convert('-Item1');
      expect(result.root.children.isEmpty, true);
    });
  });
}
