import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('ordered list decoder', () {
    final parser = DocumentMarkdownDecoder(
      markdownElementParsers: [
        const MarkdownTodoListParserV2(),
        const MarkdownUnorderedListParserV2(),
      ],
    );

    test('convert todo list', () {
      final result = parser.convert('''
- [ ] Item 1
- [x] Item 2
- [ ] Item 3
''');
      for (var i = 0; i < result.root.children.length; i++) {
        expect(result.root.children[i].toJson(), {
          'type': 'todo_list',
          'data': {
            'delta': [
              {'insert': 'Item ${i + 1}'},
            ],
            'checked': i == 1,
          },
        });
      }
    });

    test('convert todo list with nested list', () {
      final result = parser.convert('''
- [ ] Item 1
    - [ ] Item 1.1
    - [ ] Item 1.2
- [ ] Item 2
''');
      expect(result.root.children[0].toJson(), {
        'type': 'todo_list',
        'data': {
          'delta': [
            {'insert': 'Item 1'},
          ],
          'checked': false,
        },
        'children': [
          {
            'type': 'todo_list',
            'data': {
              'delta': [
                {'insert': 'Item 1.1'},
              ],
              'checked': false,
            },
          },
          {
            'type': 'todo_list',
            'data': {
              'delta': [
                {'insert': 'Item 1.2'},
              ],
              'checked': false,
            },
          },
        ],
      });
      expect(result.root.children[1].toJson(), {
        'type': 'todo_list',
        'data': {
          'delta': [
            {'insert': 'Item 2'},
          ],
          'checked': false,
        },
      });
    });

    test('if no - [ ] or - [x]', () {
      final result = parser.convert('AppFlowy');
      expect(result.root.children.isEmpty, true);
    });

    test('if no space after -[] or - []', () {
      expect(
        parser.convert('-[]Item1').root.children.isEmpty,
        true,
      );
      expect(
        parser.convert('- []Item1').root.children.isEmpty,
        true,
      );
    });

    test('if no space after -[x] or - x]', () {
      expect(
        parser.convert('-[x]Item1').root.children.isEmpty,
        true,
      );
      expect(
        parser.convert('- [x]Item1').root.children.isEmpty,
        true,
      );
    });
  });
}
