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

  group('copy_command_test.dart', () {
    testWidgets('Presses Command + A in small document and copy text',
        (tester) async {
      await _testHandleCopy(tester);
    });
  });
}

Future<void> _testHandleCopy(
  WidgetTester tester,
) async {
  final editor = tester.editor
    ..initializeWithDocument(Document.fromJson(paragraphdata));
  await editor.startTesting(platform: TargetPlatform.windows);
  await editor.updateSelection(Selection.collapsed(Position(path: [0])));
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
  deleteSelectedContent(editor.editorState);
  expect(editor.document.root.children.length, 1);
  expect(editor.document.root.children.first.delta!.isEmpty, true);
  await editor.pressKey(
    key: LogicalKeyboardKey.keyC,
    isControlPressed: Platform.isWindows || Platform.isLinux,
    isMetaPressed: Platform.isMacOS,
  );
  final clipBoardData = await AppFlowyClipboard.getData();
  //this will be null because html content is not testable
  expect(clipBoardData.html, null);
  expect(clipBoardData.text, copiedText);

  await editor.dispose();
}

const copiedText =
    "AppFlowy Editor is a highly customizable   rich-text editor";
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
