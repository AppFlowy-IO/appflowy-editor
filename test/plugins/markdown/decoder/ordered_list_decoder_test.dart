import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('ordered list decoder', () {
    final parser = DocumentMarkdownDecoder(
      markdownElementParsers: [
        const MarkdownOrderedListItemParserV2(),
        const MarkdownOrderedListParserV2(),
      ],
    );

    test('convert ordered list', () {
      final result = parser.convert('''
1. Item 1
2. Item 2
3. Item 3
''');
      for (var i = 0; i < result.root.children.length; i++) {
        expect(result.root.children[i].toJson(), {
          'type': 'numbered_list',
          'data': {
            'delta': [
              {'insert': 'Item ${i + 1}'},
            ],
          },
        });
      }
    });

    test('convert ordered list with nested list', () {
      final result = parser.convert('''
1. Item 1
    1. Item 1.1
    2. Item 1.2
2. Item 2
''');
      expect(result.root.children[0].toJson(), {
        'type': 'numbered_list',
        'data': {
          'delta': [
            {'insert': 'Item 1'},
          ],
        },
        'children': [
          {
            'type': 'numbered_list',
            'data': {
              'delta': [
                {'insert': 'Item 1.1'},
              ],
            },
          },
          {
            'type': 'numbered_list',
            'data': {
              'delta': [
                {'insert': 'Item 1.2'},
              ],
            },
          },
        ],
      });
      expect(result.root.children[1].toJson(), {
        'type': 'numbered_list',
        'data': {
          'delta': [
            {'insert': 'Item 2'},
          ],
        },
      });
    });

    test('if no numbered', () {
      final result = parser.convert('AppFlowy');
      expect(result.root.children.isEmpty, true);
    });

    test('if no space after numbered', () {
      final result = parser.convert('1.Item1');
      expect(result.root.children.isEmpty, true);
    });
  });
}
