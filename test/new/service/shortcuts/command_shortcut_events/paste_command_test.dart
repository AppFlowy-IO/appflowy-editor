import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../infra/clipboard_test.dart';
import '../../../infra/testable_editor.dart';

void main() async {
  late MockClipboard mockClipboard;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockClipboard = const MockClipboard(html: null, text: null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (message) async {
      switch (message.method) {
        case "Clipboard.getData":
          return mockClipboard.getData;
        case "Clipboard.setData":
          final args = message.arguments as Map<String, dynamic>;
          mockClipboard = mockClipboard.copyWith(
            text: args['text'],
          );
      }
      return null;
    });
  });

  group('Copy + paste', () {
    testWidgets(
      'Paste link',
      (tester) async {
        final editor = tester.editor..addParagraph(initialText: '');
        await editor.startTesting();
        await editor.updateSelection(
          Selection.collapsed(Position(path: [0], offset: 0)),
        );

        const link = 'https://appflowy.io/';
        AppFlowyClipboard.mockSetData(
          const AppFlowyClipboardData(text: link),
        );

        pasteCommand.execute(editor.editorState);
        await tester.pumpAndSettle();

        final delta = editor.nodeAtPath([0])!.delta!;
        expect(delta.toPlainText(), link);
        expect(
          delta.everyAttributes(
            (element) => element[AppFlowyRichTextKeys.href] == link,
          ),
          true,
        );

        AppFlowyClipboard.mockSetData(null);
        await editor.dispose();
      },
    );

    testWidgets(
      'Copy text contains link',
      (tester) async {
        final editor = tester.editor..addParagraph(initialText: '');
        await editor.startTesting();
        await editor.updateSelection(
          Selection.collapsed(Position(path: [0], offset: 0)),
        );

        const textWithLink = 'click https://appflowy.io/ jump to appflowy';
        AppFlowyClipboard.mockSetData(
          const AppFlowyClipboardData(text: textWithLink),
        );

        pasteCommand.execute(editor.editorState);
        await tester.pumpAndSettle();

        final delta = editor.nodeAtPath([0])!.delta!;
        expect(delta.toPlainText(), textWithLink);
        expect(
          delta.everyAttributes(
            (element) =>
                element[AppFlowyRichTextKeys.href] == 'https://appflowy.io/',
          ),
          false,
        );

        AppFlowyClipboard.mockSetData(null);
        await editor.dispose();
      },
    );

    testWidgets(
        'Presses Command + A in small document and copy text and paste text',
        (tester) async {
      await _testHandleCopyPaste(tester, Document.fromJson(paragraphData));
    });

    testWidgets(
        'Presses Command + A in small document and copy text and paste text multiple times',
        (tester) async {
      await _testHandleCopyMultiplePaste(
        tester,
        Document.fromJson(paragraphData),
      );
    });
  });

  group('paste text without formatting', () {
    testWidgets('Returns event ignored if missing selection', (tester) async {
      final editor = tester.editor;
      await editor.startTesting();
      await editor.updateSelection(null);

      final result = pasteTextWithoutFormattingCommand.execute(
        editor.editorState,
      );

      expect(result, KeyEventResult.ignored);

      await editor.dispose();
    });

    testWidgets('Returns event handled if there is a selection',
        (tester) async {
      final editor = tester.editor;

      await editor.startTesting();
      await editor.updateSelection(Selection.collapsed(Position(path: [0])));

      AppFlowyClipboard.mockSetData(
        const AppFlowyClipboardData(text: 'text'),
      );
      final result = pasteTextWithoutFormattingCommand.execute(
        editor.editorState,
      );

      expect(result, KeyEventResult.handled);

      await editor.dispose();
    });

    testWidgets('paste single line of text', (tester) async {
      final editor = tester.editor..addEmptyParagraph();
      await editor.startTesting();
      await editor.updateSelection(Selection.collapsed(Position(path: [0])));

      const text = 'Hello World!';
      AppFlowyClipboard.mockSetData(
        const AppFlowyClipboardData(text: text),
      );
      pasteTextWithoutFormattingCommand.execute(editor.editorState);
      await tester.pumpAndSettle();

      expect(editor.nodeAtPath([0])!.delta!.toPlainText(), text);
      expect(editor.nodeAtPath([1]), isNull);

      await editor.dispose();
    });

    testWidgets('paste multiple lines of text', (tester) async {
      final editor = tester.editor..addEmptyParagraph();
      await editor.startTesting();
      await editor.updateSelection(Selection.collapsed(Position(path: [0])));

      const firstLine = 'Hello World!';
      const secondLine = 'How are you?';
      AppFlowyClipboard.mockSetData(
        const AppFlowyClipboardData(text: '$firstLine\n$secondLine'),
      );
      pasteTextWithoutFormattingCommand.execute(editor.editorState);
      await tester.pumpAndSettle();

      expect(editor.nodeAtPath([0])!.delta!.toPlainText(), firstLine);
      expect(editor.nodeAtPath([1])!.delta!.toPlainText(), secondLine);
      expect(editor.nodeAtPath([2]), isNull);

      await editor.dispose();
    });

    testWidgets('paste single line of text ignoring formatting',
        (tester) async {
      final editor = tester.editor..addEmptyParagraph();
      await editor.startTesting();
      await editor.updateSelection(Selection.collapsed(Position(path: [0])));

      const text = 'Hello World!';
      AppFlowyClipboard.mockSetData(
        const AppFlowyClipboardData(text: text, html: '<b>$text</b>'),
      );
      pasteTextWithoutFormattingCommand.execute(editor.editorState);
      await tester.pumpAndSettle();

      final delta = editor.nodeAtPath([0])!.delta!;
      expect(delta.toPlainText(), text);
      expect(delta.first.attributes, isNull);

      expect(
        editor.nodeAtPath([1]),
        isNull,
        reason: 'should have only one node',
      );
      expect(
        delta.first,
        equals(delta.last),
        reason: 'should have only one delta operation',
      );

      await editor.dispose();
    });

    testWidgets('paste replacing content with destination format',
        (tester) async {
      final document = Document.fromJson(paragraphData);
      final editor = tester.editor..initializeWithDocument(document);

      await editor.startTesting();
      await editor.updateSelection(
        Selection(
          start: Position(path: [0], offset: 28),
          end: Position(path: [0], offset: 52),
        ),
      );

      const expectBefore = 'AppFlowy Editor is a highly ';
      const pasteText = 'Hello World!';
      const expectAfter = ' editor';

      AppFlowyClipboard.mockSetData(
        const AppFlowyClipboardData(text: pasteText, html: '<b>$pasteText</b>'),
      );
      pasteTextWithoutFormattingCommand.execute(editor.editorState);
      await tester.pumpAndSettle();

      final afterPasteDelta = editor.nodeAtPath([0])!.delta!;
      expect(
        afterPasteDelta.toPlainText(),
        "$expectBefore$pasteText$expectAfter",
      );

      expect(afterPasteDelta.elementAt(0).attributes, isNull);
      expect(
        (afterPasteDelta.elementAt(1) as TextInsert).text,
        "highly Hello World!",
        reason: 'should merge with destination format',
      );
      expect(
        afterPasteDelta.elementAt(1).attributes,
        {BuiltInAttributeKey.bold: true},
        reason: 'should merge with destination format',
      );
      expect(
        afterPasteDelta.elementAt(2).attributes,
        {BuiltInAttributeKey.italic: true},
      );

      await editor.dispose();
    });

    for (var position in ['start', 'end']) {
      testWidgets('paste without format if at $position of formatted text',
          (tester) async {
        const pasteText = 'text';
        const formattedText = 'Formatted text';
        final node = paragraphNode(
          delta: Delta()
            ..add(
              TextInsert(
                formattedText,
                attributes: {BuiltInAttributeKey.bold: true},
              ),
            ),
        );
        final editor = tester.editor..addNode(node);

        await editor.startTesting();
        await editor.updateSelection(
          Selection.collapsed(
            Position(
              path: [0],
              offset: position == 'start' ? 0 : formattedText.length,
            ),
          ),
        );

        AppFlowyClipboard.mockSetData(
          const AppFlowyClipboardData(
            text: pasteText,
            html: '<b>$pasteText</b>',
          ),
        );
        pasteTextWithoutFormattingCommand.execute(editor.editorState);
        await tester.pumpAndSettle();

        final afterPasteDelta = editor.nodeAtPath([0])!.delta!;
        expect(
          afterPasteDelta.toPlainText(),
          position == 'start'
              ? "$pasteText$formattedText"
              : "$formattedText$pasteText",
        );

        expect(
          (afterPasteDelta.elementAt(position == 'start' ? 0 : 1) as TextInsert)
              .text,
          pasteText,
          reason: 'should not merge pasted content',
        );
        expect(
          afterPasteDelta.elementAt(position == 'start' ? 0 : 1).attributes,
          isNull,
          reason: 'should not merge pasted content',
        );
        expect(
          (afterPasteDelta.elementAt(position == 'start' ? 1 : 0) as TextInsert)
              .text,
          formattedText,
        );
        expect(
          afterPasteDelta.elementAt(position == 'start' ? 1 : 0).attributes,
          {BuiltInAttributeKey.bold: true},
        );

        await editor.dispose();
      });
    }
  });

  group('copy_paste_extension.dart', () {
    testWidgets('Keep current node if current node is empty but not paragraph',
        (tester) async {
      final initialNode = quoteNode();
      final pasteNode = paragraphNode(text: 'hello');

      final nodeType = await _testPasteNode(tester, initialNode, pasteNode);
      expect(nodeType, initialNode.type);
    });

    testWidgets('Replace node with pasted node if current is empty paragraph',
        (tester) async {
      final initialNode = paragraphNode();
      final pasteNode = headingNode(level: 2, delta: Delta()..insert('hello'));

      final nodeType = await _testPasteNode(tester, initialNode, pasteNode);
      expect(nodeType, pasteNode.type);
    });
  });
}

Future<String> _testPasteNode(
  WidgetTester tester,
  Node initialNode,
  Node pasteNode,
) async {
  final editor = tester.editor..addNode(initialNode);

  await editor.startTesting();
  await editor.updateSelection(
    Selection.collapsed(Position(path: [0])),
  );

  AppFlowyClipboard.mockSetData(
    AppFlowyClipboardData(
      text: pasteNode.delta!.toPlainText(),
      html: documentToHTML(Document.blank()..insert([0], [pasteNode])),
    ),
  );

  pasteCommand.execute(editor.editorState);
  await tester.pumpAndSettle();

  final node = editor.nodeAtPath([0])!;

  final delta = node.delta!;
  expect(delta.toPlainText(), pasteNode.delta!.toPlainText());

  AppFlowyClipboard.mockSetData(null);
  await editor.dispose();

  return node.type;
}

Future<void> _testHandleCopyMultiplePaste(
  WidgetTester tester,
  Document document,
) async {
  final editor = tester.editor..initializeWithDocument(document);
  await editor.startTesting();
  await editor.updateSelection(Selection.collapsed(Position(path: [0])));
  await editor.pressKey(
    key: LogicalKeyboardKey.keyA,
    isControlPressed: Platform.isWindows || Platform.isLinux,
    isMetaPressed: Platform.isMacOS,
  );
  handleCopy(editor.editorState);
  deleteSelectedContent(editor.editorState);

  pasteHTML(
    editor.editorState,
    documentToHTML(Document.fromJson(paragraphData)),
  );
  expect(
    editor.editorState.document.toJson(),
    paragraphData,
  );
  await editor.updateSelection(Selection.single(path: [0], startOffset: 10));
  pasteHTML(
    editor.editorState,
    documentToHTML(Document.fromJson(paragraphData)),
  );
  expect(
    editor.document.toJson(),
    secondParagraph,
  );
  pasteHTML(
    editor.editorState,
    documentToHTML(Document.fromJson(paragraphData)),
  );
  expect(
    editor.document.toJson(),
    thirdParagraph,
  );
  await editor.dispose();
}

Future<void> _testHandleCopyPaste(
  WidgetTester tester,
  Document document,
) async {
  final editor = tester.editor..initializeWithDocument(document);
  await editor.startTesting(platform: TargetPlatform.windows);
  await editor.updateSelection(Selection.collapsed(Position(path: [0])));
  await editor.pressKey(
    key: LogicalKeyboardKey.keyA,
    isControlPressed: Platform.isWindows || Platform.isLinux,
    isMetaPressed: Platform.isMacOS,
  );
  handleCopy(editor.editorState);
  deleteSelectedContent(editor.editorState);
  await editor.updateSelection(Selection.collapsed(Position(path: [0])));
  await editor.pressKey(
    key: LogicalKeyboardKey.keyP,
    isControlPressed: Platform.isWindows || Platform.isLinux,
    isMetaPressed: Platform.isMacOS,
  );

  final clipBoardData = await AppFlowyClipboard.getData();
  handlePastePlainText(editor.editorState, clipBoardData.text!);
  expect(editor.document.toJson(), plainTextJson);

  await editor.dispose();
}

const paragraphData = {
  "document": {
    "type": "page",
    "children": [
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {'insert': 'AppFlowy Editor is a '},
            {
              'insert': 'highly customizable',
              'attributes': {'bold': true},
            },
            {'insert': '   '},
            {
              'insert': 'rich-text editor',
              'attributes': {'italic': true},
            }
          ],
        },
      }
    ],
  },
};
const secondParagraph = {
  "document": {
    "type": "page",
    "children": [
      {
        "type": "paragraph",
        "data": {
          "delta": [
            {"insert": "AppFlowy Editor is a "},
            {
              "insert": "highly customizable",
              "attributes": {"bold": true},
            },
            {"insert": "   "},
            {
              "insert": "rich-text editor",
              "attributes": {"italic": true},
            },
            {"insert": "AppFlowy Editor is a "},
            {
              "insert": "highly customizable",
              "attributes": {"bold": true},
            },
            {"insert": "   "},
            {
              "insert": "rich-text editor",
              "attributes": {"italic": true},
            }
          ],
        },
      }
    ],
  },
};
const plainTextJson = {
  "document": {
    "type": "page",
    "children": [
      {
        "type": "paragraph",
        "data": {
          "delta": [
            {
              "insert":
                  "AppFlowy Editor is a highly customizable   rich-text editor",
            }
          ],
        },
      }
    ],
  },
};
const thirdParagraph = {
  "document": {
    "type": "page",
    "children": [
      {
        "type": "paragraph",
        "data": {
          "delta": [
            {"insert": "AppFlowy Editor is a "},
            {
              "insert": "highly customizable",
              "attributes": {"bold": true},
            },
            {"insert": "   "},
            {
              "insert": "rich-text editor",
              "attributes": {"italic": true},
            },
            {"insert": "AppFlowy Editor is a "},
            {
              "insert": "highly customizable",
              "attributes": {"bold": true},
            },
            {"insert": "   "},
            {
              "insert": "rich-text editor",
              "attributes": {"italic": true},
            },
            {"insert": "AppFlowy Editor is a "},
            {
              "insert": "highly customizable",
              "attributes": {"bold": true},
            },
            {"insert": "   "},
            {
              "insert": "rich-text editor",
              "attributes": {"italic": true},
            }
          ],
        },
      }
    ],
  },
};
