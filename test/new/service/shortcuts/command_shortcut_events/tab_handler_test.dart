import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../infra/testable_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('tab_handler.dart', () {
    testWidgets('press tab in plain text', (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor..addParagraphs(2, initialText: text);
      await editor.startTesting();
      await editor.updateSelection(Selection.single(path: [0], startOffset: 0));
      await editor.pressKey(key: LogicalKeyboardKey.tab);

      expect(
        editor.selection,
        Selection.single(path: [0], startOffset: 0),
      );

      await editor.updateSelection(Selection.single(path: [1], startOffset: 0));
      await editor.pressKey(key: LogicalKeyboardKey.tab);

      expect(
        editor.selection,
        Selection.single(path: [0, 0], startOffset: 0),
      );

      await editor.dispose();
    });

    testWidgets('press tab in bulleted list', (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor
        ..addNode(bulletedListNode(delta: Delta()..insert(text)))
        ..addNode(bulletedListNode(delta: Delta()..insert(text)))
        ..addNode(bulletedListNode(delta: Delta()..insert(text)));
      await editor.startTesting();
      var document = editor.document;

      await editor.updateSelection(Selection.single(path: [0], startOffset: 0));
      await editor.pressKey(key: LogicalKeyboardKey.tab);

      // nothing happens
      expect(
        editor.selection,
        Selection.single(path: [0], startOffset: 0),
      );
      expect(editor.document.toJson(), document.toJson());

      // Before
      // * Welcome to Appflowy 😁
      // * Welcome to Appflowy 😁
      // * Welcome to Appflowy 😁
      // After
      // * Welcome to Appflowy 😁
      //  * Welcome to Appflowy 😁
      //  * Welcome to Appflowy 😁

      await editor.updateSelection(Selection.single(path: [1], startOffset: 0));

      await editor.pressKey(key: LogicalKeyboardKey.tab);

      expect(
        editor.selection,
        Selection.single(path: [0, 0], startOffset: 0),
      );
      expect(editor.nodeAtPath([0])!.type, 'bulleted_list');
      expect(editor.nodeAtPath([1])!.type, 'bulleted_list');
      expect(editor.nodeAtPath([2]), null);
      expect(
        editor.nodeAtPath([0, 0])!.type,
        'bulleted_list',
      );

      await editor.updateSelection(Selection.single(path: [1], startOffset: 0));
      await editor.pressKey(key: LogicalKeyboardKey.tab);

      expect(
        editor.selection,
        Selection.single(path: [0, 1], startOffset: 0),
      );
      expect(editor.nodeAtPath([0])!.type, 'bulleted_list');
      expect(editor.nodeAtPath([1]), null);
      expect(editor.nodeAtPath([2]), null);
      expect(
        editor.nodeAtPath([0, 0])!.type,
        'bulleted_list',
      );
      expect(
        editor.nodeAtPath([0, 1])!.type,
        'bulleted_list',
      );

      // Before
      // * Welcome to Appflowy 😁
      //  * Welcome to Appflowy 😁
      //  * Welcome to Appflowy 😁
      // After
      // * Welcome to Appflowy 😁
      //  * Welcome to Appflowy 😁
      //    * Welcome to Appflowy 😁
      document = editor.document;

      await editor
          .updateSelection(Selection.single(path: [0, 0], startOffset: 0));
      await editor.pressKey(key: LogicalKeyboardKey.tab);

      expect(
        editor.selection,
        Selection.single(path: [0, 0], startOffset: 0),
      );
      expect(editor.document.toJson(), document.toJson());

      await editor
          .updateSelection(Selection.single(path: [0, 1], startOffset: 0));
      await editor.pressKey(key: LogicalKeyboardKey.tab);

      expect(
        editor.selection,
        Selection.single(path: [0, 0, 0], startOffset: 0),
      );
      expect(
        editor.nodeAtPath([0])!.type,
        'bulleted_list',
      );
      expect(
        editor.nodeAtPath([0, 0])!.type,
        'bulleted_list',
      );
      expect(editor.nodeAtPath([0, 1]), null);
      expect(
        editor.nodeAtPath([0, 0, 0])!.type,
        'bulleted_list',
      );

      await editor.dispose();
    });

    testWidgets('press tab in checkbox/todo list', (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor
        ..addNode(todoListNode(checked: false, delta: Delta()..insert(text)))
        ..addNode(todoListNode(checked: false, delta: Delta()..insert(text)))
        ..addNode(todoListNode(checked: false, delta: Delta()..insert(text)));
      await editor.startTesting();
      Document document = editor.document;

      await editor.updateSelection(Selection.single(path: [0], startOffset: 0));
      await editor.pressKey(key: LogicalKeyboardKey.tab);

      // nothing happens
      expect(
        editor.selection,
        Selection.single(path: [0], startOffset: 0),
      );
      expect(editor.document.toJson(), document.toJson());

      // Before
      // [] Welcome to Appflowy 😁
      // [] Welcome to Appflowy 😁
      // [] Welcome to Appflowy 😁
      // After
      // [] Welcome to Appflowy 😁
      //  [] Welcome to Appflowy 😁
      //  [] Welcome to Appflowy 😁

      await editor.updateSelection(Selection.single(path: [1], startOffset: 0));

      await editor.pressKey(key: LogicalKeyboardKey.tab);

      expect(
        editor.selection,
        Selection.single(path: [0, 0], startOffset: 0),
      );
      expect(editor.nodeAtPath([0])!.type, 'todo_list');
      expect(editor.nodeAtPath([1])!.type, 'todo_list');
      expect(editor.nodeAtPath([2]), null);
      expect(editor.nodeAtPath([0, 0])!.type, 'todo_list');

      await editor.updateSelection(Selection.single(path: [1], startOffset: 0));
      await editor.pressKey(key: LogicalKeyboardKey.tab);

      expect(
        editor.selection,
        Selection.single(path: [0, 1], startOffset: 0),
      );
      expect(editor.nodeAtPath([0])!.type, 'todo_list');
      expect(editor.nodeAtPath([1]), null);
      expect(editor.nodeAtPath([2]), null);
      expect(editor.nodeAtPath([0, 0])!.type, 'todo_list');
      expect(editor.nodeAtPath([0, 1])!.type, 'todo_list');

      // Before
      // [] Welcome to Appflowy 😁
      //  [] Welcome to Appflowy 😁
      //  [] Welcome to Appflowy 😁
      // After
      // [] Welcome to Appflowy 😁
      //  [] Welcome to Appflowy 😁
      //   [] Welcome to Appflowy 😁
      document = editor.document;

      await editor
          .updateSelection(Selection.single(path: [0, 0], startOffset: 0));
      await editor.pressKey(key: LogicalKeyboardKey.tab);

      expect(
        editor.selection,
        Selection.single(path: [0, 0], startOffset: 0),
      );
      expect(editor.document.toJson(), document.toJson());

      await editor
          .updateSelection(Selection.single(path: [0, 1], startOffset: 0));
      await editor.pressKey(key: LogicalKeyboardKey.tab);

      expect(
        editor.selection,
        Selection.single(path: [0, 0, 0], startOffset: 0),
      );
      expect(
        editor.nodeAtPath([0])!.type,
        'todo_list',
      );
      expect(
        editor.nodeAtPath([0, 0])!.type,
        'todo_list',
      );
      expect(editor.nodeAtPath([0, 1]), null);
      expect(
        editor.nodeAtPath([0, 0, 0])!.type,
        'todo_list',
      );

      await editor.dispose();
    });
  });
}
