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
  group('copy_paste_handler_test.dart', () {
    testWidgets('Presses Command + A in small document and copy text',
        (tester) async {
      await _testHandleCopy(tester, Document.fromJson(paragraphData));
    });
    testWidgets('Presses Command + A in small document and copy text same node',
        (tester) async {
      await _testSameNodeCopyPaste(tester, Document.fromJson(paragraphData));
    });
    testWidgets('Presses Command + A in nested document and copy text',
        (tester) async {
      await _testHandleCopy(tester, Document.fromJson(data));
    });
    testWidgets(
        'Presses Command + A in nested document and copy text nestednode',
        (tester) async {
      // TODO: fix this test
      // await _testNestedNodeCopyPaste(tester, Document.fromJson(exampledoc));
    });

    testWidgets('update selection and execute cut command', (tester) async {
      await _testCutHandle(tester, Document.fromJson(cutData));
    });
  });
}

Future<void> _testCutHandle(
  WidgetTester tester,
  Document document,
) async {
  final editor = tester.editor..initializeWithDocument(document);

  await editor.updateSelection(
    Selection(
      start: Position(path: [2], offset: 0),
      end: Position(path: [2], offset: 69),
    ),
  );
  handleCut(editor.editorState);
  expect(
    editor.editorState.document.toJson(),
    Document.fromJson(afterCut).toJson(),
  );

  await editor.dispose();
}

Future<void> _testHandleCopy(WidgetTester tester, Document document) async {
  final editor = tester.editor..initializeWithDocument(document);
  await editor.startTesting(platform: TargetPlatform.windows);
  await editor.updateSelection(Selection.collapsed(Position(path: [0])));
  await editor.pressKey(
    key: LogicalKeyboardKey.keyA,
    isControlPressed: Platform.isWindows || Platform.isLinux,
    isMetaPressed: Platform.isMacOS,
  );
  final text =
      editor.editorState.getTextInSelection(editor.selection).join('\n');
  handleCopy(editor.editorState);
  final clipBoardData = await AppFlowyClipboard.getData();
  //this will be null because html content is not testable
  expect(clipBoardData.html, null);
  expect(clipBoardData.text, text);

  await editor.dispose();
}

Future<void> _testSameNodeCopyPaste(
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

  await editor.updateSelection(
    Selection(
      start: Position(path: [0], offset: 4),
      end: Position(path: [0], offset: 4),
    ),
  );
  pasteHTML(editor.editorState, documentToHTML(document));
  expect(
    editor.editorState.document.toJson(),
    sameNodeParagraph,
  );

  await editor.dispose();
}

// Future<void> _testNestedNodeCopyPaste(
//   WidgetTester tester,
//   Document document,
// ) async {
//   final editor = tester.editor..initializeWithDocument(document);
//   await editor.startTesting();
//   await editor.updateSelection(Selection.collapse([0], 0));
//   await editor.pressKey(
//     key: LogicalKeyboardKey.keyA,
//     isControlPressed: Platform.isWindows || Platform.isLinux,
//     isMetaPressed: Platform.isMacOS,
//   );

//   await editor.updateSelection(
//     Selection(
//       start: Position(path: [0], offset: 5),
//       end: Position(path: [0], offset: 5),
//     ),
//   );

//   pasteHTML(
//     editor.editorState,
//     documentToHTML(
//       document,
//     ),
//   );
//   final Map<String, Object> json = editor.editorState.document.toJson();

//   expect(
//     json,
//     nestedNodeParagraph,
//   );

//   await editor.dispose();
// }

const plainText = '''AppFlowyEditor
👋 Welcome to   AppFlowy Editor
AppFlowy Editor is a highly customizable   rich-text editor
   Here is an example your you can give a try
   Span element
   Span element two
   Span element three
   This is an anchor tag!
Features!
[x] Customizable
[x] Test-covered
[ ] more to come!
First item
Second item
List element
This is a quote!
 Code block
   Italic one
   Italic two
   Bold tag
You can also use AppFlowy Editor as a component to build your own app.
Awesome features
If you have questions or feedback, please submit an issue on Github or join the community along with 1000+ builders!


''';

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
const sameNodeParagraph = {
  "document": {
    "type": "page",
    "children": [
      {
        "type": "paragraph",
        "data": {
          "delta": [
            {"insert": "AppFAppFlowy Editor is a "},
            {
              "insert": "highly customizable",
              "attributes": {"bold": true},
            },
            {"insert": "   "},
            {
              "insert": "rich-text editor",
              "attributes": {"italic": true},
            },
            {"insert": "lowy Editor is a "},
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
const nestedNodeParagraph = {
  "document": {
    "type": "page",
    "children": [
      {
        "type": "heading",
        "data": {
          "level": 2,
          "delta": [
            {"insert": "👋 "},
            {
              "insert": "We",
              "attributes": {"bold": true},
            }
          ],
        },
      },
      {
        "type": "heading",
        "data": {
          "delta": [
            {"insert": "👋 "},
            {
              "insert": "Welcome to",
              "attributes": {"bold": true},
            },
            {"insert": " "},
            {
              "insert": "AppFlowy Editor",
              "attributes": {
                "href": "appflowy.io",
                "bold": true,
                "italic": true,
              },
            }
          ],
          "level": 2,
        },
      },
      {
        "type": "paragraph",
        "data": {"delta": []},
      },
      {
        "type": "paragraph",
        "data": {
          "delta": [
            {"insert": "AppFlowy Editor is a "},
            {
              "insert": "highly customizable",
              "attributes": {"bold": true},
            },
            {"insert": " "},
            {
              "insert": "rich-text editor",
              "attributes": {"italic": true},
            },
            {"insert": " for "},
            {
              "insert": "Flutter",
              "attributes": {"underline": true},
            }
          ],
        },
      },
      {
        "type": "paragraph",
        "data": {
          "delta": [
            {"insert": "Customizable"},
          ],
        },
      },
      {
        "type": "paragraph",
        "data": {"delta": []},
      },
      {
        "type": "paragraph",
        "data": {
          "delta": [
            {"insert": "Test-covered"},
          ],
        },
      },
      {
        "type": "paragraph",
        "data": {"delta": []},
      },
      {
        "type": "paragraph",
        "data": {
          "delta": [
            {"insert": "more to come!"},
          ],
        },
      },
      {
        "type": "paragraph",
        "data": {"delta": []},
      },
      {
        "type": "paragraph",
        "data": {"delta": []},
      },
      {
        "type": "quote",
        "data": {
          "delta": [
            {"insert": "Here is an example you can give a try"},
          ],
        },
      },
      {
        "type": "paragraph",
        "data": {"delta": []},
      },
      {
        "type": "paragraph",
        "data": {
          "delta": [
            {"insert": "You can also use "},
            {
              "insert": "AppFlowy Editor",
              "attributes": {"bold": true, "italic": true},
            },
            {"insert": " as a component to build your own app."},
          ],
        },
      },
      {
        "type": "paragraph",
        "data": {"delta": []},
      },
      {
        "type": "bulleted_list",
        "data": {
          "delta": [
            {"insert": "Use / to insert blocks"},
          ],
        },
      },
      {
        "type": "bulleted_list",
        "data": {
          "delta": [
            {
              "insert":
                  "Select text to trigger to the toolbar to format your notes.",
            }
          ],
        },
      },
      {
        "type": "paragraph",
        "data": {"delta": []},
      },
      {
        "type": "paragraph",
        "data": {
          "delta": [
            {
              "insert":
                  "If you have questions or feedback, please submit an issue on Github or join the community along with 1000+ builders!",
            }
          ],
        },
      },
      {
        "type": "heading",
        "data": {
          "level": 2,
          "delta": [
            {
              "insert": "lcome to",
              "attributes": {"bold": true},
            },
            {"insert": " "},
            {
              "insert": "AppFlowy Editor",
              "attributes": {
                "href": "appflowy.io",
                "italic": true,
                "bold": true,
              },
            }
          ],
        },
      },
      {
        "type": "paragraph",
        "data": {"delta": []},
      },
      {
        "type": "paragraph",
        "data": {
          "delta": [
            {"insert": "AppFlowy Editor is a"},
            {"insert": " "},
            {
              "insert": "highly customizable",
              "attributes": {"bold": true},
            },
            {"insert": " "},
            {
              "insert": "rich-text editor",
              "attributes": {"italic": true},
            },
            {"insert": " for "},
            {
              "insert": "Flutter",
              "attributes": {"underline": true},
            }
          ],
        },
      },
      {
        "type": "todo_list",
        "data": {
          "checked": true,
          "delta": [
            {"insert": "Customizable"},
          ],
        },
      },
      {
        "type": "todo_list",
        "data": {
          "checked": true,
          "delta": [
            {"insert": "Test-covered"},
          ],
        },
      },
      {
        "type": "todo_list",
        "data": {
          "checked": false,
          "delta": [
            {"insert": "more to come!"},
          ],
        },
      },
      {
        "type": "paragraph",
        "data": {"delta": []},
      },
      {
        "type": "quote",
        "data": {
          "delta": [
            {"insert": "Here is an example you can give a try"},
          ],
        },
      },
      {
        "type": "paragraph",
        "data": {"delta": []},
      },
      {
        "type": "paragraph",
        "data": {
          "delta": [
            {"insert": "You can also use "},
            {
              "insert": "AppFlowy Editor",
              "attributes": {
                "italic": true,
                "bold": true,
                "textColor": "0xffD70040",
                "highlightColor": "0x6000BCF0",
              },
            },
            {"insert": " as a component to build your own app."},
          ],
        },
      },
      {
        "type": "paragraph",
        "data": {"delta": []},
      },
      {
        "type": "bulleted_list",
        "data": {
          "delta": [
            {"insert": "Use / to insert blocks"},
          ],
        },
      },
      {
        "type": "bulleted_list",
        "data": {
          "delta": [
            {
              "insert":
                  "Select text to trigger to the toolbar to format your notes.",
            }
          ],
        },
      },
      {
        "type": "paragraph",
        "data": {"delta": []},
      },
      {
        "type": "paragraph",
        "data": {
          "delta": [
            {
              "insert":
                  "If you have questions or feedback, please submit an issue on Github or join the community along with 1000+ builders!",
            }
          ],
        },
      }
    ],
  },
};
const data = {
  'document': {
    'type': 'page',
    'children': [
      {
        'type': 'heading',
        'data': {
          'level': 1,
          'delta': [
            {'insert': 'AppFlowyEditor'},
          ],
        },
      },
      {
        'type': 'heading',
        'data': {
          'level': 2,
          'delta': [
            {'insert': '👋 '},
            {
              'insert': 'Welcome to',
              'attributes': {'bold': true},
            },
            {'insert': '   '},
            {
              'insert': 'AppFlowy Editor',
              'attributes': {'bold': true, 'italic': true},
            }
          ],
        },
      },
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
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {'insert': '   '},
            {
              'insert': 'Here',
              'attributes': {'underline': true},
            },
            {'insert': ' is an example '},
            {
              'insert': 'your',
              'attributes': {'strikethrough': true},
            },
            {'insert': ' you can give a try'},
          ],
        },
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {'insert': '   '},
            {
              'insert': 'Span element',
              'attributes': {'bold': true, 'italic': true},
            }
          ],
        },
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {'insert': '   '},
            {
              'insert': 'Span element two',
              'attributes': {'underline': true},
            }
          ],
        },
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {'insert': '   '},
            {
              'insert': 'Span element three',
              'attributes': {'bold': true, 'strikethrough': true},
            }
          ],
        },
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {'insert': '   '},
            {
              'insert': 'This is an anchor tag!',
              'attributes': {'href': 'https://appflowy.io'},
            }
          ],
        },
      },
      {
        'type': 'heading',
        'data': {
          'level': 3,
          'delta': [
            {'insert': 'Features!'},
          ],
        },
      },
      {
        'type': 'bulleted_list',
        'data': {
          'delta': [
            {'insert': '[x] Customizable'},
          ],
        },
      },
      {
        'type': 'bulleted_list',
        'data': {
          'delta': [
            {'insert': '[x] Test-covered'},
          ],
        },
      },
      {
        'type': 'bulleted_list',
        'data': {
          'delta': [
            {'insert': '[ ] more to come!'},
          ],
        },
      },
      {
        'type': 'bulleted_list',
        'data': {
          'delta': [
            {'insert': 'First item'},
          ],
        },
      },
      {
        'type': 'bulleted_list',
        'data': {
          'delta': [
            {'insert': 'Second item'},
          ],
        },
      },
      {
        'type': 'bulleted_list',
        'data': {
          'delta': [
            {'insert': 'List element'},
          ],
        },
      },
      {
        'type': 'quote',
        'data': {
          'delta': [
            {'insert': 'This is a quote!'},
          ],
        },
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {
              'insert': ' Code block',
              'attributes': {'code': true},
            }
          ],
        },
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {'insert': '   '},
            {
              'insert': 'Italic one',
              'attributes': {'italic': true},
            }
          ],
        },
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {'insert': '   '},
            {
              'insert': 'Italic two',
              'attributes': {'italic': true},
            }
          ],
        },
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {'insert': '   '},
            {
              'insert': 'Bold tag',
              'attributes': {'bold': true},
            }
          ],
        },
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {'insert': 'You can also use '},
            {
              'insert': 'AppFlowy Editor',
              'attributes': {'bold': true, 'italic': true},
            },
            {'insert': ' as a component to build your own app. '},
          ],
        },
      },
      {
        'type': 'heading',
        'data': {
          'level': 3,
          'delta': [
            {'insert': 'Awesome features'},
          ],
        },
      },
      {
        'type': 'paragraph',
        'data': {
          'delta': [
            {
              'insert':
                  'If you have questions or feedback, please submit an issue on Github or join the community along with 1000+ builders!',
            }
          ],
        },
      },
      {
        'type': 'paragraph',
        'data': {'delta': []},
      },
      {
        'type': 'paragraph',
        'data': {'delta': []},
      }
    ],
  },
};
const exampledoc = {
  "document": {
    "type": "page",
    "children": [
      {
        "type": "heading",
        "data": {
          "level": 2,
          "delta": [
            {"insert": "👋 "},
            {
              "insert": "Welcome to",
              "attributes": {"bold": true},
            },
            {"insert": " "},
            {
              "insert": "AppFlowy Editor",
              "attributes": {
                "href": "appflowy.io",
                "italic": true,
                "bold": true,
              },
            }
          ],
        },
      },
      {
        "type": "paragraph",
        "data": {"delta": []},
      },
      {
        "type": "paragraph",
        "data": {
          "delta": [
            {"insert": "AppFlowy Editor is a"},
            {"insert": " "},
            {
              "insert": "highly customizable",
              "attributes": {"bold": true},
            },
            {"insert": " "},
            {
              "insert": "rich-text editor",
              "attributes": {"italic": true},
            },
            {"insert": " for "},
            {
              "insert": "Flutter",
              "attributes": {"underline": true},
            }
          ],
        },
      },
      {
        "type": "todo_list",
        "data": {
          "checked": true,
          "delta": [
            {"insert": "Customizable"},
          ],
        },
      },
      {
        "type": "todo_list",
        "data": {
          "checked": true,
          "delta": [
            {"insert": "Test-covered"},
          ],
        },
      },
      {
        "type": "todo_list",
        "data": {
          "checked": false,
          "delta": [
            {"insert": "more to come!"},
          ],
        },
      },
      {
        "type": "paragraph",
        "data": {"delta": []},
      },
      {
        "type": "quote",
        "data": {
          "delta": [
            {"insert": "Here is an example you can give a try"},
          ],
        },
      },
      {
        "type": "paragraph",
        "data": {"delta": []},
      },
      {
        "type": "paragraph",
        "data": {
          "delta": [
            {"insert": "You can also use "},
            {
              "insert": "AppFlowy Editor",
              "attributes": {
                "italic": true,
                "bold": true,
                "textColor": "0xffD70040",
                "highlightColor": "0x6000BCF0",
              },
            },
            {"insert": " as a component to build your own app."},
          ],
        },
      },
      {
        "type": "paragraph",
        "data": {"delta": []},
      },
      {
        "type": "bulleted_list",
        "data": {
          "delta": [
            {"insert": "Use / to insert blocks"},
          ],
        },
      },
      {
        "type": "bulleted_list",
        "data": {
          "delta": [
            {
              "insert":
                  "Select text to trigger to the toolbar to format your notes.",
            }
          ],
        },
      },
      {
        "type": "paragraph",
        "data": {"delta": []},
      },
      {
        "type": "paragraph",
        "data": {
          "delta": [
            {
              "insert":
                  "If you have questions or feedback, please submit an issue on Github or join the community along with 1000+ builders!",
            }
          ],
        },
      }
    ],
  },
};
const paragraphhtml =
    "<p>AppFlowy Editor is a <strong>highly customizable</strong>   <i>rich-text editor</i></p>";
const rawHTML =
    '''<h1>AppFlowyEditor</h1><h2>👋 <strong>Welcome to</strong>   <span style="font-weight: bold; font-style: italic">AppFlowy Editor</span></h2><p>AppFlowy Editor is a <strong>highly customizable</strong>   <i>rich-text editor</i></p><p>   <u>Here</u> is an example <del>your</del> you can give a try</p><p>   <span style="font-weight: bold; font-style: italic">Span element</span></p><p>   <u>Span element two</u></p><p>   <span style="font-weight: bold; text-decoration: line-through">Span element three</span></p><p>   <a href="https://appflowy.io">This is an anchor tag!</a></p><h3>Features!</h3><ul><li>[x] Customizable</li><li>[x] Test-covered</li><li>[ ] more to come!</li><li>First item</li><li>Second item</li><li>List element</li></ul><blockquote>This is a quote!</blockquote><p><code> Code block</code></p><p>   <i>Italic one</i></p><p>   <i>Italic two</i></p><p>   <strong>Bold tag</strong></p><p>You can also use <span style="font-weight: bold; font-style: italic">AppFlowy Editor</span> as a component to build your own app. </p><h3>Awesome features</h3><p>If you have questions or feedback, please submit an issue on Github or join the community along with 1000+ builders!</p><p></p><p></p>''';
const cutData = {
  "document": {
    "type": "page",
    "children": [
      {
        "type": "heading",
        "data": {
          "level": 2,
          "delta": [
            {"insert": "👋 "},
            {
              "insert": "Welcome to",
              "attributes": {"bold": true},
            },
            {"insert": " "},
            {
              "insert": "AppFlowy Editor",
              "attributes": {
                "href": "appflowy.io",
                "italic": true,
                "bold": true,
              },
            }
          ],
        },
      },
      {
        "type": "paragraph",
        "data": {"delta": []},
      },
      {
        "type": "paragraph",
        "data": {
          "delta": [
            {"insert": "AppFlowy Editor is a"},
            {"insert": " "},
            {
              "insert": "highly customizable",
              "attributes": {"bold": true},
            },
            {"insert": " "},
            {
              "insert": "rich-text editor",
              "attributes": {"italic": true},
            },
            {"insert": " for "},
            {
              "insert": "Flutter",
              "attributes": {"underline": true},
            }
          ],
        },
      },
      {
        "type": "todo_list",
        "data": {
          "checked": true,
          "delta": [
            {"insert": "Customizable"},
          ],
        },
      },
      {
        "type": "todo_list",
        "data": {
          "checked": true,
          "delta": [
            {"insert": "Test-covered"},
          ],
        },
      },
      {
        "type": "todo_list",
        "data": {
          "checked": false,
          "delta": [
            {"insert": "more to come!"},
          ],
        },
      },
      {
        "type": "paragraph",
        "data": {"delta": []},
      },
      {
        "type": "quote",
        "data": {
          "delta": [
            {"insert": "Here is an example you can give a try"},
          ],
        },
      },
      {
        "type": "paragraph",
        "data": {"delta": []},
      },
      {
        "type": "paragraph",
        "data": {
          "delta": [
            {"insert": "You can also use "},
            {
              "insert": "AppFlowy Editor",
              "attributes": {
                "italic": true,
                "bold": true,
                "font_color": "0xffD70040",
                "bg_color": "0x6000BCF0",
              },
            },
            {"insert": " as a component to build your own app."},
          ],
        },
      },
      {
        "type": "paragraph",
        "data": {"delta": []},
      },
      {
        "type": "bulleted_list",
        "data": {
          "delta": [
            {"insert": "Use / to insert blocks"},
          ],
        },
      },
      {
        "type": "bulleted_list",
        "data": {
          "delta": [
            {
              "insert":
                  "Select text to trigger to the toolbar to format your notes.",
            }
          ],
        },
      },
      {
        "type": "paragraph",
        "data": {"delta": []},
      },
      {
        "type": "paragraph",
        "data": {
          "delta": [
            {
              "insert":
                  "If you have questions or feedback, please submit an issue on Github or join the community along with 1000+ builders!",
            }
          ],
        },
      }
    ],
  },
};
const afterCut = {
  "document": {
    "type": "page",
    "children": [
      {
        "type": "heading",
        "data": {
          "level": 2,
          "delta": [
            {"insert": "👋 "},
            {
              "insert": "Welcome to",
              "attributes": {"bold": true},
            },
            {"insert": " "},
            {
              "insert": "AppFlowy Editor",
              "attributes": {
                "href": "appflowy.io",
                "italic": true,
                "bold": true,
              },
            }
          ],
        },
      },
      {
        "type": "paragraph",
        "data": {"delta": []},
      },
      {
        "type": "paragraph",
        "data": {"delta": []},
      },
      {
        "type": "todo_list",
        "data": {
          "checked": true,
          "delta": [
            {"insert": "Customizable"},
          ],
        },
      },
      {
        "type": "todo_list",
        "data": {
          "checked": true,
          "delta": [
            {"insert": "Test-covered"},
          ],
        },
      },
      {
        "type": "todo_list",
        "data": {
          "checked": false,
          "delta": [
            {"insert": "more to come!"},
          ],
        },
      },
      {
        "type": "paragraph",
        "data": {"delta": []},
      },
      {
        "type": "quote",
        "data": {
          "delta": [
            {"insert": "Here is an example you can give a try"},
          ],
        },
      },
      {
        "type": "paragraph",
        "data": {"delta": []},
      },
      {
        "type": "paragraph",
        "data": {
          "delta": [
            {"insert": "You can also use "},
            {
              "insert": "AppFlowy Editor",
              "attributes": {
                "italic": true,
                "bold": true,
                "font_color": "0xffD70040",
                "bg_color": "0x6000BCF0",
              },
            },
            {"insert": " as a component to build your own app."},
          ],
        },
      },
      {
        "type": "paragraph",
        "data": {"delta": []},
      },
      {
        "type": "bulleted_list",
        "data": {
          "delta": [
            {"insert": "Use / to insert blocks"},
          ],
        },
      },
      {
        "type": "bulleted_list",
        "data": {
          "delta": [
            {
              "insert":
                  "Select text to trigger to the toolbar to format your notes.",
            }
          ],
        },
      },
      {
        "type": "paragraph",
        "data": {"delta": []},
      },
      {
        "type": "paragraph",
        "data": {
          "delta": [
            {
              "insert":
                  "If you have questions or feedback, please submit an issue on Github or join the community along with 1000+ builders!",
            }
          ],
        },
      }
    ],
  },
};
