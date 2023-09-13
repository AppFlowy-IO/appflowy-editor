import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../infra/testable_editor.dart';

// single | means the cursor
void main() async {
  group('open link - test', () {
    const text = 'Welcome to AppFlowy';

    // Pressing alt+enter after selecting a word should not cause
    // a newline character to be inserted,
    // rather it should execute the openLinkHandler
    testWidgets('press alt+enter when selected text is link', (tester) async {
      final editor = tester.editor
        ..initializeWithDocument(Document.fromJson(exampleJson));

      await editor.startTesting();

      final node = editor.nodeAtPath([0]);
      expect(node, isNotNull);
      expect(node!.delta, isNotNull);
      expect(node.delta!.toPlainText(), text);

      final selection = Selection.single(
        path: [0],
        startOffset: 11,
        endOffset: 'AppFlowy'.length + 11,
      );
      await editor.updateSelection(selection);

      //check if selection is link
      final nodes = editor.editorState.getNodesInSelection(selection);
      expect(
        nodes.allSatisfyInSelection(selection, (delta) {
          return delta.whereType<TextInsert>().every(
                (element) =>
                    element.attributes?[BuiltInAttributeKey.href] != null,
              );
        }),
        true,
      );

      await editor.pressKey(
        key: LogicalKeyboardKey.enter,
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
      }
    ],
  },
};
