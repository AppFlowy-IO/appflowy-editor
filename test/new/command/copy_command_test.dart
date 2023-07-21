import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../new/infra/testable_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('copy_command_test.dart', () {
    testWidgets('Presses Command + A in small document and copy text',
        (tester) async {
      await _testhandleCopy(tester, Document.fromJson(paragraphdata));
    });
  });
}

Future<void> _testhandleCopy(WidgetTester tester, Document document) async {
  final editor = tester.editor..initializeWithDocment(document);
  await editor.startTesting();
  await editor.updateSelection(Selection.collapse([0], 0));
  await editor.pressKey(
    key: LogicalKeyboardKey.keyA,
    isControlPressed: Platform.isWindows || Platform.isLinux,
    isMetaPressed: Platform.isMacOS,
  );
  await editor.pressKey(
    key: LogicalKeyboardKey.keyC,
    isControlPressed: Platform.isWindows || Platform.isLinux,
    isMetaPressed: Platform.isMacOS,
  );
  await editor.pressKey(
    key: LogicalKeyboardKey.backspace,
    isControlPressed: Platform.isWindows || Platform.isLinux,
    isMetaPressed: Platform.isMacOS,
  );
  await editor.pressKey(
    key: LogicalKeyboardKey.keyP,
    isControlPressed: Platform.isWindows || Platform.isLinux,
    isMetaPressed: Platform.isMacOS,
  );
  expect(
    editor.editorState.document.toJson(),
    document.toJson(),
  );
  await editor.dispose();
}

const paragraphText =
    '''AppFlowy Editor is a highly customizable   rich-text editor''';
const paragraphdata = {
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
              'attributes': {'bold': true}
            },
            {'insert': '   '},
            {
              'insert': 'rich-text editor',
              'attributes': {'italic': true}
            }
          ]
        }
      }
    ]
  }
};
