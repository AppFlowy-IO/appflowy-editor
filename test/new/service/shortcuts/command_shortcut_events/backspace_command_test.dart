import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/table_block_component/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../infra/testable_editor.dart';
import '../../../util/util.dart';

// single | means the cursor
// double | means the selection
void main() async {
  group('backspaceCommand - unit test', () {
    group('backspaceCommand - collapsed selection', () {
      const text = 'Welcome to AppFlowy Editor 🔥!';
      // Before
      // Welcome| to AppFlowy Editor 🔥!
      // After
      // | to AppFlowy Editor 🔥!
      test('delete in collapsed selection when the index > 0', () async {
        final document = Document.blank().addParagraph(
          initialText: text,
        );
        final editorState = EditorState(document: document);

        const index = 'Welcome'.length;
        // Welcome| to AppFlowy Editor 🔥!
        final selection = Selection.collapsed(
          Position(path: [0], offset: index),
        );
        editorState.selection = selection;
        for (var i = 0; i < index; i++) {
          final result = backspaceCommand.execute(editorState);
          expect(result, KeyEventResult.handled);
        }

        final after = editorState.getNodeAtPath([0])!;
        expect(after.delta!.toPlainText(), text.substring(index));
      });

      // Before
      // |Welcome to AppFlowy Editor 🔥!
      // After
      // |Welcome to AppFlowy Editor 🔥!
      test(
          'Delete the collapsed selection when the index is 0 and there is no previous node that contains a delta',
          () async {
        final document = Document.blank().addParagraph(
          initialText: text,
        );
        final editorState = EditorState(document: document);

        // |Welcome to AppFlowy Editor 🔥!
        final selection = Selection.collapsed(
          Position(path: [0], offset: 0),
        );
        editorState.selection = selection;

        final result = backspaceCommand.execute(editorState);
        expect(result, KeyEventResult.ignored);

        final after = editorState.getNodeAtPath([0])!;
        expect(after.delta!.toPlainText(), text);
        expect(editorState.selection, selection);
      });

      // Before
      // Welcome to AppFlowy Editor 🔥!
      // |Welcome to AppFlowy Editor 🔥!
      // After
      // Welcome to AppFlowy Editor 🔥!|Welcome to AppFlowy Editor 🔥!
      test('''Delete the collapsed selection when the index is 0
          and there is a previous node that contains a delta
          and the previous node is in the same level with the current node''',
          () async {
        final document = Document.blank().addParagraphs(
          2,
          initialText: text,
        );
        final editorState = EditorState(document: document);

        // Welcome to AppFlowy Editor 🔥!
        // |Welcome to AppFlowy Editor 🔥!
        final selection = Selection.collapsed(
          Position(path: [1], offset: 0),
        );
        editorState.selection = selection;

        final result = backspaceCommand.execute(editorState);
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
      // Welcome to AppFlowy Editor 🔥!
      //    |Welcome to AppFlowy Editor 🔥!
      // After
      // Welcome to AppFlowy Editor 🔥!
      // |Welcome to AppFlowy Editor 🔥!
      test('''Delete the collapsed selection when the index is 0
          and there is a previous node that contains a delta
          and the previous node is the parent of the current node''', () async {
        final document = Document.blank().addParagraph(
          initialText: text,
          decorator: (index, node) => node.addParagraph(
            initialText: text,
          ),
        );
        final editorState = EditorState(document: document);

        // Welcome to AppFlowy Editor 🔥!
        // |Welcome to AppFlowy Editor 🔥!
        final selection = Selection.collapsed(
          Position(path: [0, 0], offset: 0),
        );
        editorState.selection = selection;

        final result = backspaceCommand.execute(editorState);
        expect(result, KeyEventResult.handled);

        // the second node should be moved to the same level as it's parent.
        expect(editorState.getNodeAtPath([0, 1]), null);
        final after = editorState.getNodeAtPath([1])!;
        expect(after.delta!.toPlainText(), text);
        expect(
          editorState.selection,
          Selection.collapsed(
            Position(path: [1], offset: 0),
          ),
        );
      });

      test("backspace convert bullet list to paragraph but keep direction",
          () async {
        String rtlText = 'سلام';
        final document = Document.blank().addNode(
          BulletedListBlockKeys.type,
          initialText: rtlText,
          decorator: (index, node) => node.updateAttributes(
            {
              blockComponentTextDirection: blockComponentTextDirectionRTL,
            },
          ),
        );
        final editorState = EditorState(document: document);

        // Welcome to AppFlowy Editor 🔥!
        // |Welcome to AppFlowy Editor 🔥!
        final selection = Selection.collapsed(
          Position(path: [0], offset: 0),
        );
        editorState.selection = selection;

        final result = convertToParagraphCommand.execute(editorState);
        expect(result, KeyEventResult.handled);

        final node = editorState.getNodeAtPath([0])!;
        expect(node.type, ParagraphBlockKeys.type);
        expect(
          node.attributes[ParagraphBlockKeys.textDirection],
          blockComponentTextDirectionRTL,
        );
      });

      test("backspace when all is selected", () async {
        final document = Document.blank().addParagraphs(
          5,
          initialText: text,
        );
        final editorState = EditorState(document: document);

        final selection = Selection(
          start: Position(path: [0], offset: 0),
          end: Position(path: [4], offset: text.length),
        );
        editorState.updateSelectionWithReason(
          selection,
          reason: SelectionUpdateReason.selectAll,
        );

        final result = backspaceCommand.execute(editorState);
        expect(result, KeyEventResult.handled);

        expect(editorState.selection, Selection.collapsed(Position(path: [0])));
        expect(editorState.document.root.children.length, 1);

        final node = editorState.getNodeAtPath([0])!;
        expect(node.delta!.toPlainText(), ''); // empty
      });
    });

    group('backspaceCommand - not collapsed selection', () {
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

        final result = backspaceCommand.execute(editorState);
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

        final result = backspaceCommand.execute(editorState);
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

        final result = backspaceCommand.execute(editorState);
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

  group('backspaceCommand - widget test', () {
    const text = 'Welcome to AppFlowy Editor 🔥!';
    // Before
    // |Welcome| to AppFlowy Editor 🔥!
    // After
    // | to AppFlowy Editor 🔥!
    testWidgets('Delete the collapsed selection', (tester) async {
      final editor = tester.editor
        ..addParagraph(
          initialText: text,
        );
      await editor.startTesting();

      // Welcome| to AppFlowy Editor 🔥!
      const welcome = 'Welcome';
      final selection = Selection.single(
        path: [0],
        startOffset: 0,
        endOffset: welcome.length,
      );
      await editor.updateSelection(selection);

      await editor.pressKey(key: LogicalKeyboardKey.backspace);
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
        'Delete the collapsed selection and the first node can\'t have children',
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

      await editor.pressKey(key: LogicalKeyboardKey.backspace);
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
        'Delete the collapsed selection and the first node can have children',
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

      await editor.pressKey(key: LogicalKeyboardKey.backspace);
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
    testWidgets('Delete the non-text node, such as divider', (tester) async {
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

      await editor.pressKey(key: LogicalKeyboardKey.backspace);
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

    testWidgets("clear text but keep the old direction", (tester) async {
      final editor = tester.editor
        ..addNode(
          paragraphNode(
            text: 'Hello',
            textDirection: blockComponentTextDirectionLTR,
          ),
        )
        ..addNode(
          paragraphNode(
            text: 'س',
            textDirection: blockComponentTextDirectionAuto,
          ),
        );
      await editor.startTesting();

      Node node = editor.nodeAtPath([1])!;
      expect(
        node.selectable?.textDirection().name,
        blockComponentTextDirectionRTL,
      );

      final selection = Selection.collapsed(
        Position(path: [1], offset: 1),
      );
      await editor.updateSelection(selection);

      await editor.pressKey(key: LogicalKeyboardKey.backspace);
      await tester.pumpAndSettle();

      node = editor.nodeAtPath([1])!;
      expect(
        node.delta?.toPlainText().isEmpty,
        true,
      );
      expect(
        node.selectable?.textDirection().name,
        blockComponentTextDirectionRTL,
      );

      await editor.dispose();
    });
  });

  group('backspaceCommand - table tests', () {
    // Before
    // |Cell in row 1|
    // 🔽 delete from here
    // |Cell in row 2|
    // |Cell in row 3|
    // After
    // |Cell in row 1|
    // |Cell in row 2|
    // |Cell in row 3|
    testWidgets('Delete across multiple table rows,', (tester) async {
      const textRow1 = 'Cell in row 1';
      const textRow2 = 'Cell in row 2';
      const textRow3 = 'Cell in row 3';

      final tableNode = TableNode.fromList([
        [textRow1, textRow2, textRow3],
      ]);

      final editor = tester.editor..addNode(tableNode.node);

      await editor.startTesting();

      final selection = Selection.single(
        path: getCellNode(tableNode.node, 0, 1)!.childAtIndexOrNull(0)!.path,
        startOffset: 0,
        endOffset: 0,
      );

      await editor.updateSelection(selection);

      // Test press ALT + Backspace, while skip in-table backspace command.
      await editor.pressKey(
        key: LogicalKeyboardKey.backspace,
        isAltPressed: true,
      );
      await tester.pumpAndSettle();

      expect(
        getCellNode(tableNode.node, 0, 0)!
            .childAtIndexOrNull(0)!
            .delta
            ?.toPlainText(),
        textRow1,
      );

      expect(
        getCellNode(tableNode.node, 0, 1)!
            .childAtIndexOrNull(0)!
            .delta
            ?.toPlainText(),
        textRow2,
      );

      expect(
        getCellNode(tableNode.node, 0, 2)!
            .childAtIndexOrNull(0)!
            .delta
            ?.toPlainText(),
        textRow3,
      );

      // Ensure the cursor is at the start of the new second row
      expect(
        editor.selection,
        Selection.collapsed(Position(path: [0, 1, 0], offset: 0)),
      );

      await editor.dispose();
    });
  });

  // Before
  //               🔽 delete from here
  // |Cell in col 1|Cell in col 2|Cell in col 3|
  // After
  // |Cell in col 1|Cell in col 2|Cell in col 3|
  testWidgets('Delete across multiple table columns', (tester) async {
    const textCol1 = 'Cell in col 1';
    const textCol2 = 'Cell in col 2';
    const textCol3 = 'Cell in col 3';

    final tableNode = TableNode.fromList([
      [textCol1],
      [textCol2],
      [textCol3],
    ]);

    final editor = tester.editor..addNode(tableNode.node);

    await editor.startTesting();

    final selection = Selection.single(
      path: getCellNode(tableNode.node, 1, 0)!.childAtIndexOrNull(0)!.path,
      startOffset: 0,
      endOffset: 0,
    );

    await editor.updateSelection(selection);

    // Test press ALT + Backspace, while skip in-table backspace command.
    await editor.pressKey(
      key: LogicalKeyboardKey.backspace,
      isAltPressed: true,
    );
    await tester.pumpAndSettle();

    expect(
      getCellNode(tableNode.node, 0, 0)!
          .childAtIndexOrNull(0)!
          .delta
          ?.toPlainText(),
      textCol1,
    );

    expect(
      getCellNode(tableNode.node, 1, 0)!
          .childAtIndexOrNull(0)!
          .delta
          ?.toPlainText(),
      textCol2,
    );

    expect(
      getCellNode(tableNode.node, 2, 0)!
          .childAtIndexOrNull(0)!
          .delta
          ?.toPlainText(),
      textCol3,
    );

    expect(
      editor.selection,
      Selection.collapsed(Position(path: [0, 1, 0], offset: 0)),
    );

    await editor.dispose();
  });
}
