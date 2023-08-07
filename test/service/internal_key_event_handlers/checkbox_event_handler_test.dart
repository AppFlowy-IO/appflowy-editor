import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../new/infra/testable_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('checkbox_event_handler_test.dart', () {
    testWidgets('toggle checkbox with shortcut ctrl+enter', (tester) async {
      const text = 'Checkbox1';
      final editor = tester.editor
        ..addNode(
          todoListNode(
            checked: false,
            delta: Delta()..insert(text),
          ),
        );
      await editor.startTesting();
      await editor.updateSelection(
        Selection.single(path: [0], startOffset: text.length),
      );

      var node = editor.nodeAtPath([0])!;
      expect(node.type, 'todo_list');
      expect(node.attributes[TodoListBlockKeys.checked], false);

      await editor.pressKey(
        key: LogicalKeyboardKey.enter,
        isControlPressed: Platform.isWindows || Platform.isLinux,
        isMetaPressed: Platform.isMacOS,
      );

      node = editor.nodeAtPath([0])!;
      expect(node.attributes[TodoListBlockKeys.checked], true);

      await editor.updateSelection(
        Selection.single(path: [0], startOffset: text.length),
      );

      await editor.pressKey(
        key: LogicalKeyboardKey.enter,
        isControlPressed: Platform.isWindows || Platform.isLinux,
        isMetaPressed: Platform.isMacOS,
      );

      node = editor.nodeAtPath([0])!;
      expect(node.attributes[TodoListBlockKeys.checked], false);

      await editor.dispose();
    });

    testWidgets(
        'test if all checkboxes get unchecked after toggling them, if all of them were already checked',
        (tester) async {
      const text = 'Checkbox';
      final editor = tester.editor
        ..addNode(
          todoListNode(
            checked: true,
            attributes: {'delta': (Delta()..insert(text)).toJson()},
          ),
        )
        ..addNode(
          todoListNode(
            checked: true,
            attributes: {'delta': (Delta()..insert(text)).toJson()},
          ),
        )
        ..addNode(
          todoListNode(
            checked: true,
            attributes: {'delta': (Delta()..insert(text)).toJson()},
          ),
        );

      await editor.startTesting();

      final selection =
          Selection.collapsed(Position(path: [0], offset: text.length));
      await editor.updateSelection(selection);

      var nodes = editor.editorState.getNodesInSelection(selection);
      for (final node in nodes) {
        expect(node.type, 'todo_list');
        expect(node.attributes[TodoListBlockKeys.checked], true);
      }

      await editor.pressKey(
        key: LogicalKeyboardKey.enter,
        isControlPressed: Platform.isWindows || Platform.isLinux,
        isMetaPressed: Platform.isMacOS,
      );

      nodes = editor.editorState.getNodesInSelection(selection);
      for (final node in nodes) {
        expect(node.attributes[TodoListBlockKeys.checked], false);
      }

      await editor.dispose();
    });

    testWidgets(
        'test if all checkboxes get checked after toggling them, if any one of them were already checked',
        (tester) async {
      const text = 'Checkbox';
      final editor = tester.editor
        ..addNode(
          todoListNode(
            checked: false,
            attributes: {'delta': (Delta()..insert(text)).toJson()},
          ),
        )
        ..addNode(
          todoListNode(
            checked: true,
            attributes: {'delta': (Delta()..insert(text)).toJson()},
          ),
        )
        ..addNode(
          todoListNode(
            checked: false,
            attributes: {'delta': (Delta()..insert(text)).toJson()},
          ),
        );

      await editor.startTesting();

      final selection = Selection(
        start: Position(path: [0], offset: 0),
        end: Position(path: [2], offset: text.length),
      );
      await editor.updateSelection(
        selection,
      );

      await editor.pressKey(
        key: LogicalKeyboardKey.enter,
        isControlPressed: Platform.isWindows || Platform.isLinux,
        isMetaPressed: Platform.isMacOS,
      );

      final nodes = editor.editorState.getNodesInSelection(selection);
      for (final node in nodes) {
        expect(node.type, 'todo_list');
        expect(node.attributes[TodoListBlockKeys.checked], true);
      }

      await editor.dispose();
    });
  });
}
