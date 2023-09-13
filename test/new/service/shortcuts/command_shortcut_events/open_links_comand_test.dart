import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../infra/testable_editor.dart';

// single | means the cursor
void main() async {
  group('open links bulk - test', () {
    const text = 'Read the Documentation';

    // Pressing alt+shift+enter after selecting a word should not cause
    // a newline character to be inserted,
    // rather it should execute the openLinksHandler
    testWidgets('press alt+shift+enter', (tester) async {
      final editor = tester.editor
        ..initializeWithDocument(Document.fromJson(exampleJson));

      await editor.startTesting();

      final node = editor.nodeAtPath([2]);
      expect(node, isNotNull);
      expect(node!.delta, isNotNull);
      expect(node.delta!.toPlainText(), text);

      await editor.pressKey(
        key: LogicalKeyboardKey.enter,
        isShiftPressed: true,
        isAltPressed: true,
      );

      //no newline character is inserted
      expect(node.delta!.toPlainText(), text);

      await editor.dispose();
    });
  });
}

const exampleJson = {
  "document": {
    "type": "page",
    "children": [
      {
        "type": "paragraph",
        "data": {
          "level": 2,
          "delta": [
            {
              "insert": "Welcome to",
              "attributes": {"bold": true},
            },
            {"insert": " "},
            {
              "insert": "AppFlowy",
              "attributes": {"href": "appflowy.io"},
            }
          ],
        },
      },
      {
        "type": "paragraph",
        "data": {
          "level": 2,
          "delta": [
            {"insert": "Explore "},
            {
              "insert": "AppFlowy",
              "attributes": {"href": "appflowy.io"},
            },
            {"insert": " on "},
            {
              "insert": "Github",
              "attributes": {"href": "github.com/Appflowy-IO"},
            },
            {"insert": " Repos - "},
            {
              "insert": "Appflowy",
              "attributes": {"href": "https://github.com/AppFlowy-IO/AppFlowy"},
            },
            {"insert": ", "},
            {
              "insert": "Appflowy Editor",
              "attributes": {
                "href": "https://github.com/AppFlowy-IO/appflowy-editor",
              },
            },
            {"insert": ", "},
            {
              "insert": "Appflowy Cloud",
              "attributes": {
                "href": "https://github.com/AppFlowy-IO/AppFlowy-Cloud",
              },
            },
          ],
        },
      },
      {
        "type": "paragraph",
        "data": {
          "level": 2,
          "delta": [
            {"insert": "Read the "},
            {
              "insert": "Documentation",
              "attributes": {
                "href": "docs.appflowy.io/docs/essential-documentation/readme",
              },
            },
          ],
        },
      }
    ],
  },
};
