import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
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

  group('paste_command_test.dart', () {
    testWidgets(
      'Copy link',
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
