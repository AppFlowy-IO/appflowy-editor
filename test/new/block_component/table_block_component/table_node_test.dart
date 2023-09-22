import 'package:flutter_test/flutter_test.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_config.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_node.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_cell_block_component.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_block_component.dart';

void main() {
  group('table_node.dart', () {
    test('fromJson', () {
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
              },
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
                      'data': {'bold': true},
                    }
                  ],
                },
              },
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
                      'data': {'italic': true},
                    }
                  ],
                },
              },
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

      expect(tableNode.config.colMinimumWidth, 30);
      expect(tableNode.config.colDefaultWidth, 60);
      expect(tableNode.config.rowDefaultHeight, 50);

      expect(tableNode.getColWidth(0), 35);
      expect(tableNode.getColWidth(1), tableNode.config.colDefaultWidth);

      expect(tableNode.getRowHeight(0), tableNode.config.rowDefaultHeight);
      expect(tableNode.getRowHeight(1), tableNode.config.rowDefaultHeight);

      expect(
        tableNode.getCell(0, 0).children.first.toJson(),
        {
          'type': 'heading',
          'data': {
            'level': 2,
            'delta': [
              {'insert': 'a'},
            ],
          },
        },
      );
      expect(
        tableNode.getCell(1, 0).children.first.toJson(),
        {
          'type': 'paragraph',
          'data': {
            'delta': [
              {
                'insert': 'c',
                'data': {'italic': true},
              }
            ],
          },
        },
      );

      expect(
        tableNode.getCell(1, 1).children.first.toJson(),
        {
          'type': 'paragraph',
          'data': {
            'delta': [
              {'insert': 'd'},
            ],
          },
        },
      );
    });

    test('fromJson - error when columns length mismatch', () {
      final jsonData = {
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
              },
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
                      'data': {'italic': true},
                    }
                  ],
                },
              },
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
      };

      expect(() => TableNode.fromJson(jsonData), throwsAssertionError);
    });

    test('default constructor (from list of list of strings)', () {
      final tableNode = TableNode.fromList([
        ['1', '2'],
        ['3', '4'],
      ]);
      const config = TableConfig();

      expect(tableNode.config.colMinimumWidth, config.colMinimumWidth);
      expect(tableNode.config.colDefaultWidth, config.colDefaultWidth);
      expect(tableNode.config.rowDefaultHeight, config.rowDefaultHeight);
      expect(
        tableNode.node.attributes[TableBlockKeys.colMinimumWidth],
        config.colMinimumWidth,
      );

      expect(tableNode.getColWidth(0), config.colDefaultWidth);
      expect(tableNode.getColWidth(1), config.colDefaultWidth);

      expect(tableNode.getRowHeight(0), config.rowDefaultHeight);
      expect(tableNode.getRowHeight(1), config.rowDefaultHeight);

      expect(
        tableNode.getCell(0, 0).children.first.toJson(),
        {
          'type': 'paragraph',
          'data': {
            'delta': [
              {'insert': '1'},
            ],
          },
        },
      );
      expect(
        tableNode.getCell(1, 0).children.first.toJson(),
        {
          'type': 'paragraph',
          'data': {
            'delta': [
              {
                'insert': '3',
              }
            ],
          },
        },
      );

      expect(
        tableNode.getCell(1, 1).children.first.toJson(),
        {
          'type': 'paragraph',
          'data': {
            'delta': [
              {'insert': '4'},
            ],
          },
        },
      );
    });

    test('default constructor (from list of list of strings)', () {
      const config = TableConfig(
        colMinimumWidth: 10,
        colDefaultWidth: 20,
        rowDefaultHeight: 30,
      );
      final tableNode = TableNode.fromList(
        [
          ['1', '2'],
          ['3', '4'],
        ],
        config: config,
      );

      expect(tableNode.config.colMinimumWidth, config.colMinimumWidth);
      expect(tableNode.config.colDefaultWidth, config.colDefaultWidth);
      expect(tableNode.config.rowDefaultHeight, config.rowDefaultHeight);

      expect(tableNode.getColWidth(0), config.colDefaultWidth);

      expect(tableNode.getRowHeight(1), config.rowDefaultHeight);

      expect(
        tableNode.getCell(1, 0).children.first.toJson(),
        {
          'type': 'paragraph',
          'data': {
            'delta': [
              {
                'insert': '3',
              }
            ],
          },
        },
      );
    });

    test(
        'default constructor (from list of list of strings) - error when columns length mismatch',
        () {
      final listData = [
        ['1', '2'],
        ['3'],
      ];

      expect(() => TableNode.fromList(listData), throwsAssertionError);
    });

    test('colsHeight', () {
      final tableNode = TableNode.fromList([
        ['1', '2'],
        ['3', '4'],
      ]);

      expect(
        tableNode.colsHeight,
        tableNode.config.rowDefaultHeight * 2 +
            tableNode.config.borderWidth * 3,
      );
    });
  });
}
