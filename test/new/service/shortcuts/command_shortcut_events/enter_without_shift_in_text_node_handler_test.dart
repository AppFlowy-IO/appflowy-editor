import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../infra/testable_editor.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('enter_without_shift_in_text_node_handler.dart', () {
    testWidgets('Presses enter key in empty document', (tester) async {
      // Before
      //
      // [Empty Line]
      //
      // After
      //
      // [Empty Line] * 10
      //
      final editor = tester.editor..addEmptyParagraph();
      await editor.startTesting();
      await editor.updateSelection(
        Selection.single(path: [0], startOffset: 0),
      );
      // Pressing the enter key continuously.
      for (int i = 1; i <= 10; i++) {
        await editor.pressKey(
          character: '\n',
        );
        expect(editor.documentRootLen, i + 1);
        expect(
          editor.selection,
          Selection.single(path: [i], startOffset: 0),
        );
      }

      await editor.dispose();
    });

    testWidgets('Presses enter key in non-empty document', (tester) async {
      // Before
      //
      // Welcome to Appflowy 😁
      // Welcome to Appflowy 😁
      // Welcome to Appflowy 😁
      //
      // After
      //
      // Welcome to Appflowy 😁
      // Welcome to Appflowy 😁
      // [Empty Line]
      // Welcome to Appflowy 😁
      //
      const text = 'Welcome to Appflowy 😁';
      var lines = 3;

      final editor = tester.editor;
      editor.addParagraphs(lines, initialText: text);
      await editor.startTesting();

      expect(editor.documentRootLen, lines);

      // Presses the enter key in last line.
      await editor.updateSelection(
        Selection.single(path: [lines - 1], startOffset: 0),
      );
      await editor.pressKey(
        character: '\n',
      );
      lines += 1;
      expect(editor.documentRootLen, lines);
      expect(
        editor.selection,
        Selection.single(path: [lines - 1], startOffset: 0),
      );
      var lastNode = editor.nodeAtPath([lines - 1]);
      expect(lastNode != null, true);
      expect(lastNode?.type, 'paragraph');
      expect(lastNode?.delta?.toPlainText(), text);
      expect(lastNode?.previous?.delta?.toPlainText(), '');
      expect(
        lastNode?.previous?.previous?.delta?.toPlainText(),
        text,
      );

      await editor.dispose();
    });

    // Before
    //
    // Welcome to Appflowy 😁
    // [Style] Welcome to Appflowy 😁
    // [Style] Welcome to Appflowy 😁
    //
    // After
    //
    // Welcome to Appflowy 😁
    // [Empty Line]
    // [Style] Welcome to Appflowy 😁
    // [Style] Welcome to Appflowy 😁
    // [Style]
    testWidgets('Presses enter key in bulleted list', (tester) async {
      await _testStyleNeedToBeCopy(tester, 'bulleted_list');
    });

    testWidgets('Presses enter key in numbered list', (tester) async {
      await _testStyleNeedToBeCopy(tester, 'numbered_list');
    });

    testWidgets('Presses enter key in checkbox styled text', (tester) async {
      await _testStyleNeedToBeCopy(tester, 'todo_list');
    });

    testWidgets('Presses enter key in checkbox list indented', (tester) async {
      await _testListOutdent(tester, 'todo_list');
    });

    testWidgets('Presses enter key in bulleted list indented', (tester) async {
      await _testListOutdent(tester, 'bulleted_list');
    });

    testWidgets('Presses enter key in multiple selection from top to bottom',
        (tester) async {
      _testMultipleSelection(tester, true);
    });

    testWidgets('Presses enter key in multiple selection from bottom to top',
        (tester) async {
      _testMultipleSelection(tester, false);
    });

    testWidgets('Presses enter key in the first line', (tester) async {
      // Before
      //
      // Welcome to Appflowy 😁
      //
      // After
      //
      // [Empty Line]
      // Welcome to Appflowy 😁
      //
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor..addParagraph(initialText: text);
      await editor.startTesting();
      await editor.updateSelection(
        Selection.single(path: [0], startOffset: 0),
      );
      await editor.pressKey(character: '\n');
      expect(editor.documentRootLen, 2);
      expect(editor.nodeAtPath([1])?.delta?.toPlainText(), text);

      await editor.dispose();
    });
  });
}

Future<void> _testStyleNeedToBeCopy(WidgetTester tester, String style) async {
  const text = 'Welcome to Appflowy 😁';
  final attributes = {
    'delta': (Delta()..insert(text)).toJson(),
  };
  Node? node;
  if (style == 'todo_list') {
    node = todoListNode(checked: true, attributes: attributes);
  } else if (style == 'numbered_list') {
    node = numberedListNode(attributes: attributes);
  } else if (style == 'bulleted_list') {
    node = bulletedListNode(attributes: attributes);
  } else if (style == 'quote') {
    node = quoteNode(attributes: attributes);
  }
  if (node == null) {
    throw Exception('Invalid style: $style');
  }
  final editor = tester.editor
    ..addParagraph(initialText: text)
    ..addNode(node)
    ..addNode(node.copyWith());

  await editor.startTesting();
  await editor.updateSelection(
    Selection.single(path: [1], startOffset: 0),
  );
  await editor.pressKey(
    character: '\n',
  );
  expect(editor.selection, Selection.single(path: [2], startOffset: 0));

  await editor.updateSelection(
    Selection.single(path: [3], startOffset: text.length),
  );
  await editor.pressKey(
    character: '\n',
  );
  expect(editor.selection, Selection.single(path: [4], startOffset: 0));

  expect(editor.nodeAtPath([4])?.type, style);

  await editor.pressKey(
    character: '\n',
  );
  expect(
    editor.selection,
    Selection.single(path: [4], startOffset: 0),
  );
  expect(editor.nodeAtPath([4])?.type, 'paragraph');

  await editor.dispose();
}

Future<void> _testListOutdent(WidgetTester tester, String style) async {
  const text = 'Welcome to Appflowy 😁';
  final attributes = {
    'delta': (Delta()..insert(text)).toJson(),
  };
  Node? node;
  if (style == 'todo_list') {
    node = todoListNode(checked: true, attributes: attributes);
  } else if (style == 'numbered_list') {
    node = numberedListNode(attributes: attributes);
  } else if (style == 'bulleted_list') {
    node = bulletedListNode(attributes: attributes);
  }
  if (node == null) {
    throw Exception('Invalid style: $style');
  }
  final editor = tester.editor
    ..addParagraph(initialText: text)
    ..addNode(node)
    ..addNode(
      node.copyWith(
        attributes: {
          ...node.attributes,
          'delta': Delta().toJson(),
        },
      ),
    );

  await editor.startTesting();
  await editor.updateSelection(
    Selection.single(path: [2], startOffset: 0),
  );
  await editor.pressKey(
    key: LogicalKeyboardKey.tab,
  );
  expect(
    editor.selection,
    Selection.single(path: [1, 0], startOffset: 0),
  );

  await editor.pressKey(
    character: '\n',
  );
  // clear the style
  expect(
    editor.selection,
    Selection.single(path: [2], startOffset: 0),
  );
  expect(editor.nodeAtPath([2])?.type, style);

  await editor.pressKey(
    character: '\n',
  );
  expect(
    editor.selection,
    Selection.single(path: [2], startOffset: 0),
  );

  expect(editor.nodeAtPath([2])?.type, 'paragraph');

  await editor.dispose();
}

Future<void> _testMultipleSelection(
  WidgetTester tester,
  bool isBackwardSelection,
) async {
  // Before
  //
  // Welcome to Appflowy 😁
  // Welcome to Appflowy 😁
  // Welcome to Appflowy 😁
  // Welcome to Appflowy 😁
  //
  // After
  //
  // Welcome
  // to Appflowy 😁
  //
  const text = 'Welcome to Appflowy 😁';
  final editor = tester.editor;
  var lines = 4;

  editor.addParagraphs(lines, initialText: text);

  await editor.startTesting();
  final start = Position(path: [0], offset: 7);
  final end = Position(path: [3], offset: 8);
  await editor.updateSelection(
    Selection(
      start: isBackwardSelection ? start : end,
      end: isBackwardSelection ? end : start,
    ),
  );
  await editor.pressKey(
    character: '\n',
  );

  expect(editor.documentRootLen, 2);
  expect(editor.nodeAtPath([0])?.delta?.toPlainText(), 'Welcome');
  expect(editor.nodeAtPath([1])?.delta?.toPlainText(), 'to Appflowy 😁');

  await editor.dispose();
}
