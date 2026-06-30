import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_block_component.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_cell_block_component.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_config.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/table_node.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Some tests below call `updateRowHeight`, which reads `Node.rect` ->
  // `renderBox` -> `GlobalKey.currentContext`; that needs an initialized
  // binding. With no widget tree mounted, `currentContext` is null and
  // `rect` falls back to `Rect.zero`.
  TestWidgetsFlutterBinding.ensureInitialized();

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

      // it should not throw error
      expect(() => TableNode.fromJson(jsonData), isNot(throwsFlutterError));
    });

    test('default constructor (from list of list of strings)', () {
      final tableNode = TableNode.fromList([
        ['1', '2'],
        ['3', '4'],
      ]);
      final config = TableConfig();

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
      final config = TableConfig(
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

    test('updateRowHeight ignores sub-pixel jitter (no relayout loop)', () {
      // Regression test for the mobile table freeze. Layout reports
      // `rect.height` with sub-pixel jitter between frames, so the old
      // exact `!=` comparison made updateRowHeight emit a height
      // transaction every frame -> apply -> rebuild -> re-measure
      // forever, hanging the UI isolate. Detached nodes report
      // `rect == Rect.zero`, so the measured row height here is the
      // paragraph padding only (0 + 8 = 8.0).
      final tableNode = TableNode.fromList([
        ['1', '2'],
        ['3', '4'],
      ]);

      // A stored height within 1px of the measured 8.0 must be left
      // untouched so the height converges instead of oscillating.
      tableNode.getCell(0, 0).updateAttributes(
        {TableCellBlockKeys.height: 8.4},
      );
      tableNode.getCell(1, 0).updateAttributes(
        {TableCellBlockKeys.height: 8.4},
      );

      tableNode.updateRowHeight(0);

      expect(
        tableNode.getCell(0, 0).attributes[TableCellBlockKeys.height],
        8.4,
      );
      expect(
        tableNode.getCell(1, 0).attributes[TableCellBlockKeys.height],
        8.4,
      );

      // A change larger than the tolerance is still applied, so genuine
      // content resizes keep working.
      tableNode.getCell(0, 1).updateAttributes(
        {TableCellBlockKeys.height: 50.0},
      );
      tableNode.getCell(1, 1).updateAttributes(
        {TableCellBlockKeys.height: 50.0},
      );

      tableNode.updateRowHeight(1);

      expect(
        tableNode.getCell(0, 1).attributes[TableCellBlockKeys.height],
        8.0,
      );
      expect(
        tableNode.getCell(1, 1).attributes[TableCellBlockKeys.height],
        8.0,
      );
    });
  });
}
