import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('ordered list decoder', () {
    final parser = DocumentMarkdownDecoder(
      markdownElementParsers: [
        const MarkdownTableListParserV2(),
      ],
    );

    test('convert table', () {
      final result = parser.convert('''
| Month    | Savings |
| -------- | ------- |
| January  | \$250    |
| February | \$80     |
| March    | \$420    |
''');
      expect(result.root.children[0].toJson(), {
        'type': 'table',
        'children': [
          {
            'type': 'table/cell',
            'children': [
              {
                'type': 'paragraph',
                'data': {
                  'delta': [
                    {'insert': 'Month'},
                  ],
                },
              }
            ],
            'data': {
              'colPosition': 0,
              'rowPosition': 0,
              'height': 40.0,
              'width': 160.0,
            },
          },
          {
            'type': 'table/cell',
            'children': [
              {
                'type': 'paragraph',
                'data': {
                  'delta': [
                    {'insert': 'January'},
                  ],
                },
              }
            ],
            'data': {
              'colPosition': 0,
              'rowPosition': 1,
              'height': 40.0,
              'width': 160.0,
            },
          },
          {
            'type': 'table/cell',
            'children': [
              {
                'type': 'paragraph',
                'data': {
                  'delta': [
                    {'insert': 'February'},
                  ],
                },
              }
            ],
            'data': {
              'colPosition': 0,
              'rowPosition': 2,
              'height': 40.0,
              'width': 160.0,
            },
          },
          {
            'type': 'table/cell',
            'children': [
              {
                'type': 'paragraph',
                'data': {
                  'delta': [
                    {'insert': 'March'},
                  ],
                },
              }
            ],
            'data': {
              'colPosition': 0,
              'rowPosition': 3,
              'height': 40.0,
              'width': 160.0,
            },
          },
          {
            'type': 'table/cell',
            'children': [
              {
                'type': 'paragraph',
                'data': {
                  'delta': [
                    {'insert': 'Savings'},
                  ],
                },
              }
            ],
            'data': {
              'colPosition': 1,
              'rowPosition': 0,
              'height': 40.0,
              'width': 160.0,
            },
          },
          {
            'type': 'table/cell',
            'children': [
              {
                'type': 'paragraph',
                'data': {
                  'delta': [
                    {'insert': '\$250'},
                  ],
                },
              }
            ],
            'data': {
              'colPosition': 1,
              'rowPosition': 1,
              'height': 40.0,
              'width': 160.0,
            },
          },
          {
            'type': 'table/cell',
            'children': [
              {
                'type': 'paragraph',
                'data': {
                  'delta': [
                    {'insert': '\$80'},
                  ],
                },
              }
            ],
            'data': {
              'colPosition': 1,
              'rowPosition': 2,
              'height': 40.0,
              'width': 160.0,
            },
          },
          {
            'type': 'table/cell',
            'children': [
              {
                'type': 'paragraph',
                'data': {
                  'delta': [
                    {'insert': '\$420'},
                  ],
                },
              }
            ],
            'data': {
              'colPosition': 1,
              'rowPosition': 3,
              'height': 40.0,
              'width': 160.0,
            },
          }
        ],
        'data': {
          'colsLen': 2,
          'rowsLen': 4,
          'colDefaultWidth': 160.0,
          'rowDefaultHeight': 40.0,
          'colMinimumWidth': 40.0,
        },
      });
    });
  });
}
