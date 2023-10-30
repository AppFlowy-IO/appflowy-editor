import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../infra/testable_editor.dart';

void main() async {
  group('todo list power toggle', () {
    const text = 'Welcome to AppFlowy Editor 🔥!';

    // - [] Welcome to AppFlowy Editor 🔥!
    //   - [] Welcome to AppFlowy Editor 🔥!
    //     - [] Welcome to AppFlowy Editor 🔥!
    testWidgets('use power toggle', (tester) async {
      final editor = tester.editor
        ..addNode(
          todoListNode(
            delta: Delta()..insert(text),
            checked: false,
            children: [
              todoListNode(
                delta: Delta()..insert(text),
                checked: false,
                children: [
                  todoListNode(
                    delta: Delta()..insert(text),
                    checked: false,
                    children: [],
                  ),
                ],
              ),
            ],
          ),
        );

      await editor.startTesting();

      Node n1 = editor.document.root.children.first;
      Node n2 = n1.children.first;
      Node n3 = n2.children.first;

      expect(n1.attributes[TodoListBlockKeys.checked], false);
      expect(n2.attributes[TodoListBlockKeys.checked], false);
      expect(n3.attributes[TodoListBlockKeys.checked], false);

      final finder = find.byType(EditorSvg).first;
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
      await tester.tap(finder);
      await tester.pumpAndSettle();

      n1 = editor.document.root.children.first;
      n2 = n1.children.first;
      n3 = n2.children.first;

      expect(n1.attributes[TodoListBlockKeys.checked], true);
      expect(n2.attributes[TodoListBlockKeys.checked], true);
      expect(n3.attributes[TodoListBlockKeys.checked], true);

      await editor.dispose();
    });
  });
}
