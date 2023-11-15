import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_node.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  List<HTMLNodeParser> parser = [
    const HTMLTextNodeParser(),
    const HTMLBulletedListNodeParser(),
    const HTMLNumberedListNodeParser(),
    const HTMLTodoListNodeParser(),
    const HTMLQuoteNodeParser(),
    const HTMLHeadingNodeParser(),
    const HTMLImageNodeParser(),
    const HtmlTableNodeParser(),
  ];
  group('html_image_node_parser.dart', () {
    test('table node parser test', () {
      final tableNode = TableNode.fromJson({
        'type': TableBlockKeys.type,
        'data': {
          TableBlockKeys.colsLen: 2,
          TableBlockKeys.rowsLen: 2,
          TableBlockKeys.colDefaultWidth: 60,
          TableBlockKeys.rowDefaultHeight: 50,
          TableBlockKeys.colMinimumWidth: 30,
        },
        'children': [
          {
            'type': TableCellBlockKeys.type,
            'data': {
              TableCellBlockKeys.colPosition: 0,
              TableCellBlockKeys.rowPosition: 0,
              TableCellBlockKeys.width: 35,
            },
            'children': [
              {
                'type': 'heading',
                'data': {
                  'level': 2,
                  'delta': [
                    {'insert': 'a'},
                  ],
                },
              }
            ],
          },
          {
            'type': TableCellBlockKeys.type,
            'data': {
              TableCellBlockKeys.colPosition: 0,
              TableCellBlockKeys.rowPosition: 1,
            },
            'children': [
              {
                'type': 'paragraph',
                'data': {
                  'delta': [
                    {
                      'insert': 'b',
                      'attributes': {'bold': true},
                    }
                  ],
                },
              }
            ],
          },
          {
            'type': TableCellBlockKeys.type,
            'data': {
              TableCellBlockKeys.colPosition: 1,
              TableCellBlockKeys.rowPosition: 0,
            },
            'children': [
              {
                'type': 'paragraph',
                'data': {
                  'delta': [
                    {
                      'insert': 'c',
                      'attributes': {'italic': true},
                    }
                  ],
                },
              }
            ],
          },
          {
            'type': TableCellBlockKeys.type,
            'data': {
              TableCellBlockKeys.colPosition: 1,
              TableCellBlockKeys.rowPosition: 1,
            },
            'children': [
              {
                'type': 'paragraph',
                'data': {
                  'delta': [
                    {'insert': 'd'},
                  ],
                },
              }
            ],
          }
        ],
      });

      expect(
        const HtmlTableNodeParser().transformNodeToHTMLString(
          tableNode.node,
          encodeParsers: parser,
        ),
        '''<table><tr><td><h2>a</h2></td><td><p><i>c</i></p></td></tr><tr><td><p><strong>b</strong></p></td><td><p>d</p></td></tr></table>''',
      );
    });
  });
}
