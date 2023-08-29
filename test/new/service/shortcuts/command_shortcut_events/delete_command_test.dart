import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../infra/testable_editor.dart';
import '../../../util/util.dart';

// single | means the cursor
// double | means the selection
void main() async {
  group('deleteCommand - unit test', () {
    group('deleteCommand - collapsed selection', () {
      const text = 'Welcome to AppFlowy Editor 🔥!';
      // Before
      // Welcome to AppFlowy Editor 🔥!
      // After
      // Welcome | AppFlowy Editor 🔥!
      test('delete in collapsed selection when the index > 0', () async {
        final document = Document.blank().addParagraph(
          initialText: text,
        );
        final editorState = EditorState(document: document);

        const index = 'to'.length;
        // Welcome |to AppFlowy Editor 🔥!
        final selection = Selection.collapsed(
          Position(path: [0], offset: 8),
        );
        editorState.selection = selection;
        for (var i = 0; i < index; i++) {
          final result = deleteCommand.execute(editorState);
          expect(result, KeyEventResult.handled);
        }

        final after = editorState.getNodeAtPath([0])!;
        expect(after.delta!.toPlainText(), "Welcome  AppFlowy Editor 🔥!");
      });

      // Before
      // Welcome to AppFlowy Editor 🔥!|
      // After
      // Welcome to AppFlowy Editor 🔥!|
      test(
          'Do nothing when the index is at the very end and there is no next node that contains a delta',
          () async {
        final document = Document.blank().addParagraph(
          initialText: text,
        );
        final editorState = EditorState(document: document);

        // Welcome to AppFlowy Editor 🔥!|
        final selection = Selection.collapsed(
          Position(path: [0], offset: text.length),
        );
        editorState.selection = selection;

        final result = deleteCommand.execute(editorState);
        expect(result, KeyEventResult.ignored);

        final after = editorState.getNodeAtPath([0])!;
        expect(after.delta!.toPlainText(), text);
        expect(editorState.selection, selection);
      });

      // Before
      // Welcome to AppFlowy Editor 🔥!|
      // Welcome to AppFlowy Editor 🔥!
      // After
      // Welcome to AppFlowy Editor 🔥!|Welcome to AppFlowy Editor 🔥!
      test('''Delete the collapsed selection when the index is content.length
          and there is a next node that contains a delta
          and the next node is in the same level with the current node''',
          () async {
        final document = Document.blank().addParagraphs(
          2,
          initialText: text,
        );
        final editorState = EditorState(document: document);

        // Welcome to AppFlowy Editor 🔥!|
        // Welcome to AppFlowy Editor 🔥!
        final selection = Selection.collapsed(
          Position(path: [0], offset: text.length),
        );
        editorState.selection = selection;

        final result = deleteCommand.execute(editorState);
        expect(result, KeyEventResult.handled);

        // the second node should be deleted.
        expect(editorState.getNodeAtPath([1]), null);

        // the first node should be combined with the second node.
        final after = editorState.getNodeAtPath([0])!;
        expect(after.delta!.toPlainText(), text * 2);
        expect(
          editorState.selection,
          Selection.collapsed(
            Position(path: [0], offset: text.length),
          ),
        );
      });

      // Before
      // Welcome to AppFlowy Editor 🔥!|
      //    Welcome to AppFlowy Editor 🔥!
      // After
      // Welcome to AppFlowy Editor 🔥!|Welcome to AppFlowy Editor 🔥!
      //
      test('''Delete the collapsed selection's next node when cursor is at end
            and current node contains a delta
            and the next node is the child of the current node''', () async {
        //here we pass another paragraph node to the decorator,
        //this makes it a child of the first paragraph node.
        final document = Document.blank().addParagraph(
          initialText: text,
          decorator: (index, node) => node.addParagraph(
            initialText: text,
          ),
        );
        final editorState = EditorState(document: document);

        // Welcome to AppFlowy Editor 🔥!|
        //  Welcome to AppFlowy Editor 🔥!
        final selection = Selection.collapsed(
          Position(path: [0], offset: text.length),
        );
        editorState.selection = selection;

        final result = deleteCommand.execute(editorState);
        expect(result, KeyEventResult.handled);

        // the first node should be combined with the second node.
        expect(editorState.getNodeAtPath([0, 1]), null);
        final after = editorState.getNodeAtPath([0])!;
        expect(after.delta!.toPlainText(), text * 2);
        expect(
          editorState.selection,
          Selection.collapsed(
            Position(path: [0], offset: text.length),
          ),
        );
      });
    });

    group('deleteCommand - not collapsed selection', () {
      const text = 'Welcome to AppFlowy Editor 🔥!';

      // Before
      // |Welcome to AppFlowy |Editor 🔥!
      // After
      // |Editor 🔥!
      test('Delete in the not collapsed selection that is single', () async {
        final document = Document.blank().addParagraph(
          initialText: text,
        );
        final editorState = EditorState(document: document);

        // |Welcome to AppFlowy |Editor 🔥!
        const deleteText = 'Welcome to AppFlowy ';
        final selection = Selection.single(
          path: [0],
          startOffset: 0,
          endOffset: deleteText.length,
        );
        editorState.selection = selection;

        final result = deleteCommand.execute(editorState);
        expect(result, KeyEventResult.handled);

        final after = editorState.getNodeAtPath([0])!;
        expect(
          after.delta!.toPlainText(),
          text.substring(deleteText.length),
        );
        expect(
          editorState.selection,
          selection.collapse(atStart: true),
        );
      });

      // Before
      // Welcome| to AppFlowy Editor 🔥!
      // Welcome| to AppFlowy Editor 🔥!
      // After
      // Welcome| to AppFlowy Editor 🔥!
      test('Delete in the not collapsed selection that is not single',
          () async {
        final document = Document.blank().addParagraphs(
          2,
          initialText: text,
        );
        final editorState = EditorState(document: document);

        const index = 'Welcome'.length;
        // Welcome| to AppFlowy Editor 🔥!
        // Welcome| to AppFlowy Editor 🔥!
        final selection = Selection(
          start: Position(path: [0], offset: index),
          end: Position(path: [1], offset: index),
        );
        editorState.selection = selection;

        final result = deleteCommand.execute(editorState);
        expect(result, KeyEventResult.handled);

        final after = editorState.getNodeAtPath([0])!;
        expect(after.delta!.toPlainText(), text);
        expect(editorState.getNodeAtPath([1]), null);
      });

      // Before
      // Welcome| to AppFlowy Editor 🔥!
      // Welcome to AppFlowy Editor 🔥!
      //    Welcome| to AppFlowy Editor 🔥!
      //        Welcome to AppFlowy Editor 🔥!
      // After
      // Welcome| to AppFlowy Editor 🔥!
      //    Welcome to AppFlowy Editor 🔥!
      test(
          'Delete in the not collapsed selection that is not single and not flatted',
          () async {
        final document = Document.blank()
            .addParagraph(
              initialText: text,
            ) // Welcome to AppFlowy Editor 🔥!
            .addParagraph(
              initialText: text,
              decorator: (index, node) => node.addParagraph(
                initialText: text,
                decorator: (index, node) => node.addParagraph(
                  initialText: text,
                ),
              ),
            );
        assert(document.nodeAtPath([1, 0, 0]) != null, true);
        final editorState = EditorState(document: document);

        // Welcome| to AppFlowy Editor 🔥!
        // Welcome to AppFlowy Editor 🔥!
        //    Welcome| to AppFlowy Editor 🔥!
        //        Welcome to AppFlowy Editor 🔥!
        const index = 'Welcome'.length;
        final selection = Selection(
          start: Position(path: [0], offset: index),
          end: Position(path: [1, 0], offset: index),
        );
        editorState.selection = selection;

        final result = deleteCommand.execute(editorState);
        expect(result, KeyEventResult.handled);

        // Welcome| to AppFlowy Editor 🔥!
        //    Welcome to AppFlowy Editor 🔥!
        expect(
          editorState.selection,
          selection.collapse(atStart: true),
        );

        // the [1] node should be deleted.
        expect(editorState.getNodeAtPath([1]), null);

        expect(editorState.getNodeAtPath([0])?.delta?.toPlainText(), text);
        expect(editorState.getNodeAtPath([0, 0])?.delta?.toPlainText(), text);
      });
    });
  });

  group('deleteCommand - widget test', () {
    const text = 'Welcome to AppFlowy Editor 🔥!';
    // Before
    // |Welcome| to AppFlowy Editor 🔥!
    // After
    // | to AppFlowy Editor 🔥!
    testWidgets('Delete the not collapsed selection', (tester) async {
      TestableEditor editor = tester.editor
        ..addParagraph(
          initialText: text,
        );
      await editor.startTesting();

      // |Welcome| to AppFlowy Editor 🔥!
      const welcome = 'Welcome';
      final selection = Selection.single(
        path: [0],
        startOffset: 0,
        endOffset: welcome.length,
      );
      await editor.updateSelection(selection);

      await simulateKeyDownEvent(LogicalKeyboardKey.delete);
      await tester.pumpAndSettle();

      // the first node should be deleted.
      expect(
        editor.nodeAtPath([0])?.delta?.toPlainText(),
        text.substring(welcome.length),
      );

      await editor.dispose();
    });

    // Before
    // # Welcome to |AppFlowy Editor 🔥!
    // * Welcome to |AppFlowy Editor 🔥!
    //  * Welcome to AppFlowy Editor 🔥!
    // After
    // # Welcome to AppFlowy Editor 🔥!
    // * Welcome to AppFlowy Editor 🔥!
    testWidgets(
        'Delete the non collapsed selection and the first node can\'t have children',
        (tester) async {
      final delta = Delta()..insert(text);
      final editor = tester.editor
        ..addNode(headingNode(level: 1, delta: delta))
        ..addNode(
          bulletedListNode(
            delta: delta,
            children: [bulletedListNode(delta: delta)],
          ),
        );

      await editor.startTesting();

      const welcome = 'Welcome to ';
      final selection = Selection(
        start: Position(
          path: [0],
          offset: welcome.length,
        ),
        end: Position(
          path: [1],
          offset: welcome.length,
        ),
      );
      await editor.updateSelection(selection);

      await simulateKeyDownEvent(LogicalKeyboardKey.delete);
      await tester.pumpAndSettle();

      expect(
        editor.nodeAtPath([0])?.delta?.toPlainText(),
        text,
      );

      final bulletedNode = editor.nodeAtPath([1])!;
      expect(bulletedNode.type, BulletedListBlockKeys.type);
      expect(bulletedNode.delta!.toPlainText(), text);

      await editor.dispose();
    });

    // Before
    // * Welcome to |AppFlowy Editor 🔥!
    // * Welcome to |AppFlowy Editor 🔥!
    //  * Welcome to AppFlowy Editor 🔥!
    // After
    // # Welcome to AppFlowy Editor 🔥!
    // * Welcome to AppFlowy Editor 🔥!
    testWidgets(
        'Delete the non collapsed selection and the first node can have children',
        (tester) async {
      final delta = Delta()..insert(text);
      final editor = tester.editor
        ..addNode(bulletedListNode(delta: delta))
        ..addNode(
          bulletedListNode(
            delta: delta,
            children: [bulletedListNode(delta: delta)],
          ),
        );

      await editor.startTesting();

      const welcome = 'Welcome to ';
      final selection = Selection(
        start: Position(
          path: [0],
          offset: welcome.length,
        ),
        end: Position(
          path: [1],
          offset: welcome.length,
        ),
      );
      await editor.updateSelection(selection);

      await simulateKeyDownEvent(LogicalKeyboardKey.delete);
      await tester.pumpAndSettle();

      expect(
        editor.nodeAtPath([0])?.delta?.toPlainText(),
        text,
      );

      final bulletedNode = editor.nodeAtPath([0, 0])!;
      expect(bulletedNode.type, BulletedListBlockKeys.type);
      expect(bulletedNode.delta!.toPlainText(), text);

      await editor.dispose();
    });

    // Before
    // Welcome to AppFlowy Editor 🔥!
    // |---|
    // Welcome to AppFlowy Editor 🔥!
    // After
    // Welcome to AppFlowy Editor 🔥!
    // |Welcome to AppFlowy Editor 🔥!
    testWidgets('Delete the non-text node after selecting it, such as divider',
        (tester) async {
      final editor = tester.editor
        ..addParagraph(initialText: text)
        ..addNode(dividerNode())
        ..addParagraph(initialText: text);

      await editor.startTesting();

      final selection = Selection.single(
        path: [1],
        startOffset: 0,
        endOffset: 1,
      );
      await editor.updateSelection(selection);

      await simulateKeyDownEvent(LogicalKeyboardKey.delete);
      await tester.pumpAndSettle();

      expect(
        editor.nodeAtPath([1])?.delta?.toPlainText(),
        text,
      );
      expect(
        editor.selection,
        Selection.collapsed(Position(path: [1])),
      );

      await editor.dispose();
    });
  });
}
