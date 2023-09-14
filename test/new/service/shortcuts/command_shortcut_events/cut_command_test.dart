import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../infra/testable_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });
  group('cut_command_test.dart', () {
    testWidgets('update selection and execute cut command', (tester) async {
      await _testCutHandle(tester, Document.fromJson(paragraphdata));
    });
  });
}

Future<void> _testCutHandle(
  WidgetTester tester,
  Document document,
) async {
  final editor = tester.editor..initializeWithDocument(document);
  await editor.startTesting();
  await editor.updateSelection(
    Selection(
      start: Position(path: [2], offset: 0),
      end: Position(path: [2], offset: 69),
    ),
  );
  await editor.pressKey(
    key: LogicalKeyboardKey.keyX,
    isControlPressed: Platform.isWindows || Platform.isLinux,
    isMetaPressed: Platform.isMacOS,
  );

  expect(
    editor.editorState.document.toJson(),
    Document.fromJson(afterCut).toJson(),
  );

  await editor.dispose();
}

const paragraphdata = {
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
