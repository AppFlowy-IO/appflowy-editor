import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../new/infra/testable_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('outdent_handler.dart', () {
    testWidgets("press shift tab in plain text", (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor..addParagraphs(3, initialText: text);
      await editor.startTesting();

      final snapshotDocument = editor.document;

      await editor.updateSelection(Selection.single(path: [0], startOffset: 0));
      await editor.pressKey(
        key: LogicalKeyboardKey.tab,
        isShiftPressed: true,
      );
      // nothing happens
      expect(
        editor.selection,
        Selection.single(path: [0], startOffset: 0),
      );
      expect(editor.document.toJson(), snapshotDocument.toJson());
    });

    testWidgets("press shift tab where previous element is not list element",
        (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor
        ..addParagraph(initialText: text)
        ..addNode(bulletedListNode(delta: Delta()..insert(text)))
        ..addNode(bulletedListNode(delta: Delta()..insert(text)));
      await editor.startTesting();

      final snapshotDocument = editor.document;

      final selection = Selection.single(path: [1], startOffset: 0);
      await editor.updateSelection(selection);
      await editor.pressKey(
        key: LogicalKeyboardKey.tab,
        isShiftPressed: true,
      );
      // nothing happens
      expect(
        editor.selection,
        Selection.single(path: [1], startOffset: 0),
      );
      expect(editor.document.toJson(), snapshotDocument.toJson());

      await editor.dispose();
    });

    testWidgets(
      "press shift tab in indented list with multiple nodes in same sub-level",
      (tester) async {
        const text = 'Welcome to Appflowy 😁';
        final editor = tester.editor
          ..addNode(todoListNode(checked: false, delta: Delta()..insert(text)))
          ..addNode(todoListNode(checked: false, delta: Delta()..insert(text)))
          ..addNode(todoListNode(checked: false, delta: Delta()..insert(text)));

        await editor.startTesting();

        final selection = Selection.collapsed(Position(path: [1]));
        await editor.updateSelection(selection);
        await editor.pressKey(key: LogicalKeyboardKey.tab);

        await editor.updateSelection(selection);
        await editor.pressKey(key: LogicalKeyboardKey.tab);

        // Before
        // [] Welcome to Appflowy 😁
        // [] Welcome to Appflowy 😁
        // [] Welcome to Appflowy 😁
        // After
        // [] Welcome to Appflowy 😁
        //    [] Welcome to Appflowy 😁
        //    [] Welcome to Appflowy 😁

        expect(
          editor.selection,
          Selection.collapsed(Position(path: [0, 1])),
        );
        expect(
          editor.nodeAtPath([0])!.type,
          'todo_list',
        );
        expect(editor.nodeAtPath([1]), null);
        expect(editor.nodeAtPath([2]), null);
        expect(
          editor.nodeAtPath([0, 0])!.type,
          'todo_list',
        );
        expect(
          editor.nodeAtPath([0, 1])!.type,
          'todo_list',
        );

        await editor.updateSelection(
          Selection.single(path: [0, 1], startOffset: 0),
        );

        await editor.pressKey(
          key: LogicalKeyboardKey.tab,
          isShiftPressed: true,
        );

        // Before
        // [] Welcome to Appflowy 😁
        //    [] Welcome to Appflowy 😁
        //    [] Welcome to Appflowy 😁
        // After
        // [] Welcome to Appflowy 😁
        //    [] Welcome to Appflowy 😁
        // [] Welcome to Appflowy 😁

        expect(
          editor.nodeAtPath([1])!.type,
          'todo_list',
        );
        expect(
          editor.nodeAtPath([0, 0])!.type,
          'todo_list',
        );
        expect(editor.nodeAtPath([0, 1]), null);

        await editor.dispose();
      },
    );

    testWidgets(
      "press shift tab in indented list with only one node in same sub-level",
      (tester) async {
        const text = 'Welcome to Appflowy 😁';
        final editor = tester.editor
          ..addNode(bulletedListNode(delta: Delta()..insert(text)))
          ..addNode(bulletedListNode(delta: Delta()..insert(text)))
          ..addNode(bulletedListNode(delta: Delta()..insert(text)));

        await editor.startTesting();

        var selection = Selection.single(path: [1], startOffset: 0);
        await editor.updateSelection(selection);

        await editor.pressKey(key: LogicalKeyboardKey.tab);

        // Before
        // * Welcome to Appflowy 😁
        // * Welcome to Appflowy 😁
        // * Welcome to Appflowy 😁
        // After
        // * Welcome to Appflowy 😁
        //  * Welcome to Appflowy 😁
        // * Welcome to Appflowy 😁

        expect(
          editor.selection,
          Selection.single(path: [0, 0], startOffset: 0),
        );
        expect(
          editor.nodeAtPath([0])!.type,
          'bulleted_list',
        );
        expect(
          editor.nodeAtPath([0, 0])!.type,
          'bulleted_list',
        );
        expect(
          editor.nodeAtPath([1])!.type,
          'bulleted_list',
        );
        expect(editor.nodeAtPath([2]), null);

        await editor
            .updateSelection(Selection.single(path: [0, 0], startOffset: 0));

        await editor.pressKey(
          key: LogicalKeyboardKey.tab,
          isShiftPressed: true,
        );

        // Before
        // * Welcome to Appflowy 😁
        // * Welcome to Appflowy 😁
        // * Welcome to Appflowy 😁
        // After
        // * Welcome to Appflowy 😁
        // * Welcome to Appflowy 😁
        // * Welcome to Appflowy 😁

        expect(
          editor.nodeAtPath([0])!.type,
          'bulleted_list',
        );
        expect(
          editor.nodeAtPath([1])!.type,
          'bulleted_list',
        );
        expect(
          editor.nodeAtPath([2])!.type,
          'bulleted_list',
        );
        expect(editor.nodeAtPath([0, 0]), null);

        await editor.dispose();
      },
    );
  });
}
