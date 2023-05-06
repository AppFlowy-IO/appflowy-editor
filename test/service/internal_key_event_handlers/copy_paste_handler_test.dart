import 'dart:io';

import 'package:appflowy_editor/src/infra/clipboard.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import '../../infra/test_editor.dart';
import 'package:appflowy_editor/src/infra/node_store.dart';
import 'package:rich_clipboard_platform_interface/rich_clipboard_platform_interface.dart';

class MockRichClipboardPlatform extends RichClipboardPlatform {
  String? text;
  String? html;

  MockRichClipboardPlatform({
    this.text,
    this.html,
  });

  @override
  Future<List<String>> getAvailableTypes() async {
    return [];
  }

  @override
  Future<RichClipboardData> getData() async {
    return RichClipboardData(text: text, html: html);
  }

  @override
  Future<void> setData(RichClipboardData data) async {
    html = data.html;
    text = data.text;
  }
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    RichClipboardPlatform.instance = MockRichClipboardPlatform();
  });

  group('_handleCopy', () {
    testWidgets('copy image if it is the only block selected', (tester) async {
      final editor = tester.editor..insertImageNode("https://images.squarespace-cdn.com/content/v1/617f6f16b877c06711e87373/c3f23723-37f4-44d7-9c5d-6e2a53064ae7/Asset+10.png?format=1500w");
      await editor.startTesting();
      await editor.updateSelection(
        Selection.single(path: [0], startOffset: 0),
      );

      if (Platform.isWindows || Platform.isLinux) {
        await editor.pressLogicKey(
          key: LogicalKeyboardKey.keyC,
          isControlPressed: true,
        );
      } else {
        await editor.pressLogicKey(
          key: LogicalKeyboardKey.keyC,
          isMetaPressed: true,
        );
      }

      final saveNodes = NodeStore.getNodes();
      expect(saveNodes[0].toJson().toString(), '{type: image, attributes: {image_src: https://images.squarespace-cdn.com/content/v1/617f6f16b877c06711e87373/c3f23723-37f4-44d7-9c5d-6e2a53064ae7/Asset+10.png?format=1500w, align: center}}');
    });
  });

  group('_handlePaste', () {
    testWidgets('paste image if it has already been copied', (tester) async {
      final node = Node(type: "image", attributes: Attributes.from({ "image_src": "https://images.squarespace-cdn.com/content/v1/617f6f16b877c06711e87373/c3f23723-37f4-44d7-9c5d-6e2a53064ae7/Asset+10.png?format=1500w", "align": "center"}));
      final nodes = [ node ];

      final htmlString = NodesToHTMLConverter(
        nodes: [node],
        startOffset: 0,
        endOffset: 0,
      ).toHTMLString();

      NodeStore.saveNodes(nodes);
      AppFlowyClipboard.setData(
        text: '',
        html: htmlString,
      );

      final editor = tester.editor..insertEmptyTextNode();
      await editor.startTesting();
      await editor.updateSelection(
        Selection.single(path: [0], startOffset: 0),
      );

      if (Platform.isWindows || Platform.isLinux) {
        await editor.pressLogicKey(
          key: LogicalKeyboardKey.keyV,
          isControlPressed: true,
        );
      } else {
        await editor.pressLogicKey(
          key: LogicalKeyboardKey.keyV,
          isMetaPressed: true,
        );
      }

      final pastedNode = editor.editorState.document.nodeAtPath([1]);
      expect(pastedNode?.toJson().toString(), "{type: image, attributes: {image_src: https://images.squarespace-cdn.com/content/v1/617f6f16b877c06711e87373/c3f23723-37f4-44d7-9c5d-6e2a53064ae7/Asset+10.png?format=1500w, align: center}}");
    });
  });
}