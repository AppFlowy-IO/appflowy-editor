import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/heading_block_component/heading_command_shortcut.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../util/util.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });
  group('heading_command_shortcut_test.dart', () {
    const text = 'Welcome to AppFlowy Editor 🔥!';

    test('toggle H1 from paragraph', () {
      final document = Document.blank()
        ..addParagraph(
          initialText: text,
        );

      final editorState = EditorState(document: document);

      Node node = editorState.getNodeAtPath([0])!;
      expect(node.type, ParagraphBlockKeys.type);

      final selection = Selection.collapsed(
        Position(
          path: [0],
          offset: 1,
        ),
      );

      editorState.selection = selection;
      toggleH1.execute(editorState);

      // Before
      // Welcome to AppFlowy Editor 🔥!
      // After
      // <H1>Welcome to AppFlowy Editor 🔥! <H1>
      node = editorState.getNodeAtPath([0])!;
      expect(node.type, HeadingBlockKeys.type);
      expect(node.level, 1);

      toggleH1.execute(editorState);
      // Before
      // <H1>Welcome to AppFlowy Editor 🔥! <H1>
      // After
      // Welcome to AppFlowy Editor 🔥!
      expect(editorState.getNodeAtPath([0])!.type, ParagraphBlockKeys.type);
    });

    test('toggle H2 from paragraph', () {
      final document = Document.blank()
        ..addParagraph(
          initialText: text,
        );

      final editorState = EditorState(document: document);

      Node node = editorState.getNodeAtPath([0])!;
      expect(node.type, ParagraphBlockKeys.type);

      final selection = Selection.collapsed(
        Position(
          path: [0],
          offset: 1,
        ),
      );

      editorState.selection = selection;
      toggleH2.execute(editorState);

      // Before
      // Welcome to AppFlowy Editor 🔥!
      // After
      // <H2>Welcome to AppFlowy Editor 🔥! <H2>
      node = editorState.getNodeAtPath([0])!;
      expect(node.type, HeadingBlockKeys.type);
      expect(node.attributes[HeadingBlockKeys.level], 2);

      toggleH2.execute(editorState);
      // Before
      // <H2>Welcome to AppFlowy Editor 🔥! <H2>
      // After
      // Welcome to AppFlowy Editor 🔥!
      expect(editorState.getNodeAtPath([0])!.type, ParagraphBlockKeys.type);
    });

    test('toggle H3 from paragraph', () {
      final document = Document.blank()
        ..addParagraph(
          initialText: text,
        );

      final editorState = EditorState(document: document);

      Node node = editorState.getNodeAtPath([0])!;
      expect(node.type, ParagraphBlockKeys.type);

      final selection = Selection.collapsed(
        Position(
          path: [0],
          offset: 1,
        ),
      );

      editorState.selection = selection;
      toggleH3.execute(editorState);

      // Before
      // Welcome to AppFlowy Editor 🔥!
      // After
      // <H3>Welcome to AppFlowy Editor 🔥! <H3>
      node = editorState.getNodeAtPath([0])!;
      expect(node.type, HeadingBlockKeys.type);
      expect(node.attributes[HeadingBlockKeys.level], 3);

      toggleH3.execute(editorState);
      // Before
      // <H3>Welcome to AppFlowy Editor 🔥! <H3>
      // After
      // Welcome to AppFlowy Editor 🔥!
      expect(editorState.getNodeAtPath([0])!.type, ParagraphBlockKeys.type);
    });

    test('toggle body type from heading type', () {
      final document = Document.blank()
        ..insert([0], [headingNode(level: 2, text: text)]);

      final editorState = EditorState(document: document);

      Node node = editorState.getNodeAtPath([0])!;
      expect(node.type, HeadingBlockKeys.type);
      expect(node.attributes[HeadingBlockKeys.level], 2);

      final selection = Selection.collapsed(
        Position(
          path: [0],
          offset: 1,
        ),
      );

      editorState.selection = selection;
      toggleBody.execute(editorState);

      // Before
      // <H2>Welcome to AppFlowy Editor 🔥! <H2>
      // After
      // Welcome to AppFlowy Editor 🔥!
      node = editorState.getNodeAtPath([0])!;
      expect(node.type, ParagraphBlockKeys.type);
    });

    // Regression test for real data loss on a real page, 2026-07-27.
    //
    // The delta was read ONCE from the block at `selection.start` and then
    // written into every block the format callback ran for. Toggling a heading
    // over a multi-block selection therefore stamped the first block's text
    // over all the others and destroyed their writing. This shortcut path has
    // no single-selection gate, so any selection could trigger it.
    test('toggling a heading over several blocks keeps each blocks own text',
        () {
      final document = Document.blank()
        ..addParagraph(initialText: 'first')
        ..addParagraph(initialText: 'second')
        ..addParagraph(initialText: 'third');
      final editorState = EditorState(document: document);

      editorState.selection = Selection(
        start: Position(path: [0]),
        end: Position(path: [2], offset: 'third'.length),
      );
      toggleH1.execute(editorState);

      final texts = editorState.document.root.children
          .map((n) => n.delta?.toPlainText())
          .toList();
      expect(texts, ['first', 'second', 'third']);
      expect(
        editorState.document.root.children.map((n) => n.type),
        everyElement(HeadingBlockKeys.type),
      );

      // ...and back again, which is the same callback with the other type.
      toggleH1.execute(editorState);
      expect(
        editorState.document.root.children
            .map((n) => n.delta?.toPlainText())
            .toList(),
        ['first', 'second', 'third'],
      );
    });
  });
}
