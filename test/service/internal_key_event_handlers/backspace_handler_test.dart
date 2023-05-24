import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../new/infra/testable_editor.dart';
import '../../new/util/util.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    if (kDebugMode) {
      activateLog();
    }
  });

  tearDownAll(() {
    if (kDebugMode) {
      deactivateLog();
    }
  });

  group('backspace_handler.dart', () {
    testWidgets('Presses backspace key in empty document', (tester) async {
      // Before
      //
      // [Empty Line]
      //
      // After
      //
      // [Empty Line]
      //
      final editor = tester.editor..addEmptyParagraph();
      await editor.startTesting();
      await editor.updateSelection(
        Selection.single(path: [0], startOffset: 0),
      );
      // Pressing the backspace key continuously.
      for (int i = 1; i <= 10; i++) {
        await editor.pressKey(
          key: LogicalKeyboardKey.backspace,
        );
        expect(editor.documentRootLen, 1);
        expect(
          editor.selection,
          Selection.single(path: [0], startOffset: 0),
        );
      }
      await editor.dispose();
    });
  });

  // Before
  //
  // Welcome to Appflowy 😁
  // Welcome to Appflowy 😁
  // Welcome to Appflowy 😁
  //
  // After
  //
  // Welcome to Appflowy 😁
  // Welcome t Appflowy 😁
  // Welcome Appflowy 😁
  //
  // Then
  // Welcome to Appflowy 😁
  //
  testWidgets(
      'Presses backspace key in non-empty document and selection is backward',
      (tester) async {
    await _deleteTextByBackspace(tester, true);
  });

  testWidgets(
      'Presses backspace key in non-empty document and selection is forward',
      (tester) async {
    await _deleteTextByBackspace(tester, false);
  });

  // Before
  //
  // Welcome to Appflowy 😁
  // Welcome to Appflowy 😁
  // Welcome to Appflowy 😁
  //
  // After
  //
  // Welcome to Appflowy 😁
  // Welcome t Appflowy 😁
  // Welcome Appflowy 😁
  //
  // Then
  // Welcome to Appflowy 😁
  //
  // testWidgets(
  //     'Presses delete key in non-empty document and selection is backward',
  //     (tester) async {
  //   await _deleteTextByDelete(tester, true);
  // });

  // testWidgets(
  //     'Presses delete key in non-empty document and selection is forward',
  //     (tester) async {
  //   await _deleteTextByDelete(tester, false);
  // });

  // Before
  //
  // Welcome to Appflowy 😁
  // Welcome to Appflowy 😁
  //
  // After
  //
  // Welcome to Appflowy 😁Welcome Appflowy 😁
  // testWidgets(
  //     'Presses delete key in non-empty document and selection is at the end of the text',
  //     (tester) async {
  //   const text = 'Welcome to Appflowy 😁';
  //   final editor = tester.editor..addParagraphs(2, initialText: text);
  //   await editor.startTesting();

  //   // delete 'o'
  //   await editor.updateSelection(
  //     Selection.single(path: [0], startOffset: text.length),
  //   );
  //   await editor.pressLogicKey(key: LogicalKeyboardKey.delete);

  //   expect(editor.documentRootLen, 1);
  //   expect(
  //     editor.documentRootLen,
  //     Selection.single(path: [0], startOffset: text.length),
  //   );
  //   expect(editor.nodeAtPath([0])?.delta?.toPlainText(), text * 2);
  // });

  // Before
  //
  // Welcome to Appflowy 😁
  // [Style] Welcome to Appflowy 😁
  // [Style] Welcome to Appflowy 😁
  //
  // After
  //
  // Welcome to Appflowy 😁
  // [Style] Welcome to Appflowy 😁Welcome to Appflowy 😁
  //
  testWidgets('Presses backspace key in styled text (todo_list)',
      (tester) async {
    await _deleteStyledTextByBackspace(tester, 'todo_list');
  });

  testWidgets('Presses backspace key in styled text (bulletedList)',
      (tester) async {
    await _deleteStyledTextByBackspace(
      tester,
      'bulleted_list',
    );
  });

  testWidgets('Presses backspace key in styled text (heading)', (tester) async {
    await _deleteStyledTextByBackspace(tester, 'heading');
  });

  testWidgets('Presses backspace key in styled text (quote)', (tester) async {
    await _deleteStyledTextByBackspace(tester, 'quote');
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
  // [Style] Welcome to Appflowy 😁
  //
  testWidgets('Presses delete key in styled text (checkbox)', (tester) async {
    await _deleteStyledTextByDelete(tester, BuiltInAttributeKey.checkbox);
  });

  testWidgets('Presses delete key in styled text (bulletedList)',
      (tester) async {
    await _deleteStyledTextByDelete(tester, 'bulleted_list');
  });

  testWidgets('Presses delete key in styled text (heading)', (tester) async {
    await _deleteStyledTextByDelete(tester, BuiltInAttributeKey.heading);
  });

  testWidgets('Presses delete key in styled text (quote)', (tester) async {
    await _deleteStyledTextByDelete(tester, BuiltInAttributeKey.quote);
  });

  // Before
  //
  // Welcome to Appflowy 😁
  // Welcome to Appflowy 😁
  // [Image]
  // Welcome to Appflowy 😁
  // Welcome to Appflowy 😁
  //
  // After
  //
  // Welcome to Appflowy 😁
  // Welcome to Appflowy 😁
  //
  // testWidgets('Deletes the image surrounded by text', (tester) async {
  //   mockNetworkImagesFor(() async {
  //     const text = 'Welcome to Appflowy 😁';
  //     const src = 'https://s1.ax1x.com/2022/08/26/v2sSbR.jpg';
  //     final editor = tester.editor
  //       ..insertTextNode(text)
  //       ..insertTextNode(text)
  //       ..insertImageNode(src)
  //       ..insertTextNode(text)
  //       ..insertTextNode(text);
  //     await editor.startTesting();

  //     expect(editor.documentRootLen, 5);
  //     expect(find.byType(ImageNodeWidget), findsOneWidget);

  //     await editor.updateSelection(
  //       Selection(
  //         start: Position(path: [1], offset: 0),
  //         end: Position(path: [3], offset: text.length),
  //       ),
  //     );

  //     await editor.pressLogicKey(key: LogicalKeyboardKey.backspace);
  //     expect(editor.documentRootLen, 3);
  //     expect(find.byType(ImageNodeWidget), findsNothing);
  //     expect(
  //       editor.selection,
  //       Selection.single(path: [1], startOffset: 0),
  //     );
  //   });
  // });

  testWidgets('Deletes the first image, and selection is backward',
      (tester) async {
    await _deleteFirstImage(tester, true);
  });

  testWidgets('Deletes the first image, and selection is not backward',
      (tester) async {
    await _deleteFirstImage(tester, false);
  });

  testWidgets('Deletes the last image and selection is backward',
      (tester) async {
    await _deleteLastImage(tester, true);
  });

  testWidgets('Deletes the last image and selection is not backward',
      (tester) async {
    await _deleteLastImage(tester, false);
  });

  testWidgets('Removes the style of heading text and revert', (tester) async {
    const text = 'Welcome to Appflowy 😁';
    final editor = tester.editor..addParagraph(initialText: text);
    await editor.startTesting();

    await editor.updateSelection(
      Selection.single(path: [0], startOffset: 0),
    );

    await editor.editorState.insertTextAtCurrentSelection('#');
    await editor.pressKey(key: LogicalKeyboardKey.space);

    var after = editor.nodeAtPath([0])!;
    expect(
      after.type,
      'heading',
    );
    expect(after.attributes[HeadingBlockKeys.level], 1);

    await editor.pressKey(key: LogicalKeyboardKey.backspace);
    after = editor.nodeAtPath([0])!;
    expect(
      after.type,
      'paragraph',
    );

    await editor.editorState.insertTextAtCurrentSelection('##');
    await editor.pressKey(key: LogicalKeyboardKey.space);
    after = editor.nodeAtPath([0])!;
    expect(
      after.type,
      'heading',
    );
    expect(after.attributes[HeadingBlockKeys.level], 2);

    await editor.dispose();
  });

  testWidgets('Delete the nested bulleted list', (tester) async {
    // * Welcome to Appflowy 😁
    //  * Welcome to Appflowy 😁
    //    * Welcome to Appflowy 😁
    const text = 'Welcome to Appflowy 😁';
    final node = bulletedListNode(
      attributes: {
        'delta': (Delta()..insert(text)).toJson(),
      },
    );
    node.insert(
      node.copyWith()
        ..insert(
          node.copyWith(),
        ),
    );
    final editor = tester.editor..addNode(node);
    await editor.startTesting();

    // * Welcome to Appflowy 😁
    //  * Welcome to Appflowy 😁
    // Welcome to Appflowy 😁
    await editor.updateSelection(
      Selection.single(path: [0, 0, 0], startOffset: 0),
    );
    await editor.pressKey(key: LogicalKeyboardKey.backspace);
    expect(editor.nodeAtPath([0, 0, 0])?.type, 'paragraph');

    await editor.updateSelection(
      Selection.single(path: [0, 0, 0], startOffset: 0),
    );
    await editor.pressKey(key: LogicalKeyboardKey.backspace);
    expect(editor.nodeAtPath([0, 1]) != null, true);

    await editor.updateSelection(
      Selection.single(path: [0, 1], startOffset: 0),
    );
    await editor.pressKey(key: LogicalKeyboardKey.backspace);
    expect(editor.nodeAtPath([1]) != null, true);

    await editor.updateSelection(
      Selection.single(path: [1], startOffset: 0),
    );

    // * Welcome to Appflowy 😁
    //  * Welcome to Appflowy 😁Welcome to Appflowy 😁
    await editor.pressKey(key: LogicalKeyboardKey.backspace);
    expect(
      editor.selection,
      Selection.single(path: [0, 0], startOffset: text.length),
    );
    expect(editor.nodeAtPath([0, 0])?.delta?.toPlainText(), text * 2);

    await editor.dispose();
  });

  testWidgets('Delete the complicated nested bulleted list', (tester) async {
    // * Welcome to Appflowy 😁
    //  * Welcome to Appflowy 😁
    //  * Welcome to Appflowy 😁
    //    * Welcome to Appflowy 😁
    //    * Welcome to Appflowy 😁
    const text = 'Welcome to Appflowy 😁';
    final node = bulletedListNode(
      attributes: {
        'delta': (Delta()..insert(text)).toJson(),
      },
    );
    node
      ..insert(
        node.copyWith(children: []),
      )
      ..insert(
        node.copyWith(children: [])
          ..insert(
            node.copyWith(children: []),
          )
          ..insert(
            node.copyWith(children: []),
          ),
      );
    final editor = tester.editor..addNode(node);
    await editor.startTesting();

    await editor.updateSelection(
      Selection.single(path: [0, 1], startOffset: 0),
    );
    await editor.pressKey(key: LogicalKeyboardKey.backspace);
    expect(
      editor.nodeAtPath([0, 1])!.type != 'bulleted_list',
      true,
    );

    expect(
      editor.nodeAtPath([0, 1, 0])!.type,
      'bulleted_list',
    );

    expect(
      editor.nodeAtPath([0, 1, 1])!.type,
      'bulleted_list',
    );

    expect(find.byType(FlowyRichText), findsNWidgets(5));

    // Before
    // * Welcome to Appflowy 😁
    //  * Welcome to Appflowy 😁
    //  Welcome to Appflowy 😁
    //    * Welcome to Appflowy 😁
    //    * Welcome to Appflowy 😁
    // After
    // * Welcome to Appflowy 😁
    //  * Welcome to Appflowy 😁Welcome to Appflowy 😁
    //  * Welcome to Appflowy 😁
    //  * Welcome to Appflowy 😁
    await editor.pressKey(key: LogicalKeyboardKey.backspace);
    expect(
      editor.nodeAtPath([0, 0])!.type == 'bulleted_list',
      true,
    );

    expect(
      editor.nodeAtPath([0, 0])?.delta?.toPlainText() == text * 2,
      true,
    );

    expect(
      editor.nodeAtPath([0, 1])!.type == 'bulleted_list',
      true,
    );

    expect(
      editor.nodeAtPath([0, 2])!.type == 'bulleted_list',
      true,
    );

    await editor.dispose();
  });
}

Future<void> _deleteFirstImage(WidgetTester tester, bool isBackward) async {
  // FIXME: migrate to new editor
  // mockNetworkImagesFor(() async {
  //   const text = 'Welcome to Appflowy 😁';
  //   const src = 'https://s1.ax1x.com/2022/08/26/v2sSbR.jpg';
  //   final editor = tester.editor
  //     ..insertImageNode(src)
  //     ..insertTextNode(text)
  //     ..insertTextNode(text);
  //   await editor.startTesting();

  //   expect(editor.documentRootLen, 3);
  //   expect(find.byType(ImageNodeWidget), findsOneWidget);

  //   final start = Position(path: [0], offset: 0);
  //   final end = Position(path: [1], offset: 1);
  //   await editor.updateSelection(
  //     Selection(
  //       start: isBackward ? start : end,
  //       end: isBackward ? end : start,
  //     ),
  //   );

  //   await editor.pressLogicKey(key: LogicalKeyboardKey.backspace);
  //   expect(editor.documentRootLen, 2);
  //   expect(find.byType(ImageNodeWidget), findsNothing);
  //   expect(editor.selection, Selection.collapsed(start));
  // });
}

Future<void> _deleteLastImage(WidgetTester tester, bool isBackward) async {
  // FIXME: migrate to new editor
  // mockNetworkImagesFor(() async {
  //   const text = 'Welcome to Appflowy 😁';
  //   const src = 'https://s1.ax1x.com/2022/08/26/v2sSbR.jpg';
  //   final editor = tester.editor
  //     ..insertTextNode(text)
  //     ..insertTextNode(text)
  //     ..insertImageNode(src);
  //   await editor.startTesting();

  //   expect(editor.documentRootLen, 3);
  //   expect(find.byType(ImageNodeWidget), findsOneWidget);

  //   final start = Position(path: [1], offset: 0);
  //   final end = Position(path: [2], offset: 1);
  //   await editor.updateSelection(
  //     Selection(
  //       start: isBackward ? start : end,
  //       end: isBackward ? end : start,
  //     ),
  //   );

  //   await editor.pressLogicKey(key: LogicalKeyboardKey.backspace);
  //   expect(editor.documentRootLen, 2);
  //   expect(find.byType(ImageNodeWidget), findsNothing);
  //   expect(editor.selection, Selection.collapsed(start));
  // });
}
Future<void> _deleteStyledTextByBackspace(
  WidgetTester tester,
  String type,
) async {
  const text = 'Welcome to Appflowy 😁';
  final attributes = {
    'delta': (Delta()..insert(text)).toJson(),
  };
  Node? node;
  if (type == 'todo_list') {
    node = todoListNode(
      attributes: attributes,
      checked: true,
    );
  } else if (type == 'numbered_list') {
    node = numberedListNode(
      attributes: attributes,
    );
  } else if (type == 'heading') {
    node = headingNode(
      attributes: attributes,
      level: 1,
    );
  } else if (type == 'quote') {
    node = quoteNode(
      attributes: attributes,
    );
  } else if (type == 'bulleted_list') {
    node = bulletedListNode(
      attributes: attributes,
    );
  }
  if (node == null) {
    throw Exception('Invalid type: $type');
  }
  final editor = tester.editor
    ..addParagraph(initialText: text)
    ..addNode(node)
    ..addNode(node.copyWith());

  await editor.startTesting();
  await editor.updateSelection(
    Selection.single(path: [2], startOffset: 0),
  );
  await editor.pressKey(
    key: LogicalKeyboardKey.backspace,
  );
  expect(editor.selection, Selection.single(path: [2], startOffset: 0));
  expect(editor.nodeAtPath([2])?.type, 'paragraph');

  await editor.pressKey(
    key: LogicalKeyboardKey.backspace,
  );
  expect(editor.documentRootLen, 2);
  expect(
    editor.selection,
    Selection.single(path: [1], startOffset: text.length),
  );
  final after = editor.nodeAtPath([1])!;
  expect(after.type, type);
  expect(after.delta?.toPlainText(), text * 2);

  await editor.updateSelection(
    Selection.single(path: [1], startOffset: 0),
  );
  await editor.pressKey(
    key: LogicalKeyboardKey.backspace,
  );
  expect(editor.documentRootLen, 2);
  expect(editor.selection, Selection.single(path: [1], startOffset: 0));
  expect(editor.nodeAtPath([1])?.type, 'paragraph');

  await editor.dispose();
}

Future<void> _deleteStyledTextByDelete(
  WidgetTester tester,
  String style,
) async {
  // FIXME: migrate the delete key.
  // const text = 'Welcome to Appflowy 😁';
  // Attributes attributes = {
  //   BuiltInAttributeKey.type: style,
  // };
  // if (style == BuiltInAttributeKey.checkbox) {
  //   attributes[BuiltInAttributeKey.checkbox] = true;
  // } else if (style == BuiltInAttributeKey.numberList) {
  //   attributes[BuiltInAttributeKey.number] = 1;
  // } else if (style == BuiltInAttributeKey.heading) {
  //   attributes[BuiltInAttributeKey.heading] = BuiltInAttributeKey.h1;
  // }
  // final editor = tester.editor
  //   ..insertTextNode(text)
  //   ..insertTextNode(text, attributes: attributes)
  //   ..insertTextNode(text, attributes: attributes);

  // await editor.startTesting();
  // await editor.updateSelection(
  //   Selection.single(path: [1], startOffset: 0),
  // );
  // for (var i = 1; i < text.length; i++) {
  //   await editor.pressLogicKey(
  //     key: LogicalKeyboardKey.delete,
  //   );
  //   expect(
  //     editor.selection,
  //     Selection.single(path: [1], startOffset: 0),
  //   );
  //   expect(editor.nodeAtPath([1])?.type, style);
  //   expect(
  //     (editor.nodeAtPath([1]) as TextNode).toPlainText(),
  //     text.safeSubString(i),
  //   );
  // }

  // await editor.pressLogicKey(
  //   key: LogicalKeyboardKey.delete,
  // );
  // expect(editor.documentRootLen, 2);
  // expect(editor.selection, Selection.single(path: [1], startOffset: 0));
  // expect(editor.nodeAtPath([1])?.type, style);
  // expect((editor.nodeAtPath([1]) as TextNode).toPlainText(), text);
}

Future<void> _deleteTextByBackspace(
  WidgetTester tester,
  bool isBackwardSelection,
) async {
  const text = 'Welcome to Appflowy 😁';
  final editor = tester.editor..addParagraphs(3, initialText: text);
  await editor.startTesting();

  // delete 'o'
  await editor.updateSelection(
    Selection.single(path: [1], startOffset: 10),
  );
  await editor.pressKey(key: LogicalKeyboardKey.backspace);

  expect(editor.documentRootLen, 3);
  expect(editor.selection, Selection.single(path: [1], startOffset: 9));
  expect(
    editor.nodeAtPath([1])?.delta?.toPlainText(),
    'Welcome t Appflowy 😁',
  );

  // delete 'to '
  await editor.updateSelection(
    Selection.single(path: [2], startOffset: 8, endOffset: 11),
  );
  await editor.pressKey(key: LogicalKeyboardKey.backspace);
  expect(editor.documentRootLen, 3);
  expect(editor.selection, Selection.single(path: [2], startOffset: 8));
  expect(
    editor.nodeAtPath([2])?.delta?.toPlainText(),
    'Welcome Appflowy 😁',
  );

  // delete 'Appflowy 😁
  // Welcome t Appflowy 😁
  // Welcome '
  final start = Position(path: [0], offset: 11);
  final end = Position(path: [2], offset: 8);
  await editor.updateSelection(
    Selection(
      start: isBackwardSelection ? start : end,
      end: isBackwardSelection ? end : start,
    ),
  );
  await editor.pressKey(key: LogicalKeyboardKey.backspace);
  expect(editor.documentRootLen, 1);
  expect(
    editor.selection,
    Selection.single(path: [0], startOffset: 11),
  );
  expect(
    editor.nodeAtPath([0])?.delta?.toPlainText(),
    'Welcome to Appflowy 😁',
  );
  await editor.dispose();
}

Future<void> _deleteTextByDelete(
  WidgetTester tester,
  bool isBackwardSelection,
) async {
  const text = 'Welcome to Appflowy 😁';
  final editor = tester.editor..addParagraphs(3, initialText: text);
  await editor.startTesting();

  // delete 'o'
  await editor.updateSelection(
    Selection.single(path: [1], startOffset: 9),
  );
  await editor.pressKey(key: LogicalKeyboardKey.delete);

  expect(editor.documentRootLen, 3);
  expect(editor.selection, Selection.single(path: [1], startOffset: 9));
  expect(
    editor.nodeAtPath([1])?.delta?.toPlainText(),
    'Welcome t Appflowy 😁',
  );

  // delete 'to '
  await editor.updateSelection(
    Selection.single(path: [2], startOffset: 8, endOffset: 11),
  );
  await editor.pressKey(key: LogicalKeyboardKey.delete);
  expect(editor.documentRootLen, 3);
  expect(editor.selection, Selection.single(path: [2], startOffset: 8));
  expect(
    editor.nodeAtPath([2])?.delta?.toPlainText(),
    'Welcome Appflowy 😁',
  );

  // delete 'Appflowy 😁
  // Welcome t Appflowy 😁
  // Welcome '
  final start = Position(path: [0], offset: 11);
  final end = Position(path: [2], offset: 8);
  await editor.updateSelection(
    Selection(
      start: isBackwardSelection ? start : end,
      end: isBackwardSelection ? end : start,
    ),
  );
  await editor.pressKey(key: LogicalKeyboardKey.delete);
  expect(editor.documentRootLen, 1);
  expect(
    editor.selection,
    Selection.single(path: [0], startOffset: 11),
  );
  expect(
    editor.nodeAtPath([0])?.delta?.toPlainText(),
    'Welcome to Appflowy 😁',
  );

  await editor.dispose();
}
