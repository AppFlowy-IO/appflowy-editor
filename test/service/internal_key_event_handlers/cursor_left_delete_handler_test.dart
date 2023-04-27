import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../infra/test_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('cursor_left_delete_handler.dart', () {
    testWidgets('Presses ctrl + backspace to delete a word', (tester) async {
      List<String> words = ["Welcome", " ", "to", " ", "Appflowy", " ", "😁"];
      final text = words.join();
      final editor = tester.editor..insertTextNode(text);

      await editor.startTesting();
      await editor.updateSelection(
        Selection.single(path: [0], startOffset: text.length),
      );

      if (Platform.isWindows || Platform.isLinux) {
        await editor.pressLogicKey(
          key: LogicalKeyboardKey.backspace,
          isControlPressed: true,
        );
      } else {
        await editor.pressLogicKey(
          key: LogicalKeyboardKey.backspace,
          isAltPressed: true,
        );
      }

      //fetching all the text that is still on the editor.
      var nodes =
          editor.editorState.service.selectionService.currentSelectedNodes;
      var textNode = nodes.whereType<TextNode>().first;

      words.removeLast();
      //expected: Welcome_to_Appflowy_
      //here _ actually represents ' '
      expect(textNode.toPlainText(), words.join());

      if (Platform.isWindows || Platform.isLinux) {
        await editor.pressLogicKey(
          key: LogicalKeyboardKey.backspace,
          isControlPressed: true,
        );
      } else {
        await editor.pressLogicKey(
          key: LogicalKeyboardKey.backspace,
          isAltPressed: true,
        );
      }

      //fetching all the text that is still on the editor.
      nodes = editor.editorState.service.selectionService.currentSelectedNodes;
      textNode = nodes.whereType<TextNode>().first;

      //removes the whitespace
      words.removeLast();
      words.removeLast();
      //expected is: Welcome_to_
      expect(textNode.toPlainText(), words.join());

      //we divide words.length by 2 becuase we know half words are whitespaces.
      for (var i = 0; i < words.length / 2; i++) {
        if (Platform.isWindows || Platform.isLinux) {
          await editor.pressLogicKey(
            key: LogicalKeyboardKey.backspace,
            isControlPressed: true,
          );
        } else {
          await editor.pressLogicKey(
            key: LogicalKeyboardKey.backspace,
            isAltPressed: true,
          );
        }
      }

      nodes = editor.editorState.service.selectionService.currentSelectedNodes;
      textNode = nodes.whereType<TextNode>().toList(growable: false).first;

      expect(textNode.toPlainText(), '');
    });

    testWidgets('ctrl+backspace in the middle of a word', (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor..insertTextNode(text);

      await editor.startTesting();
      await editor.updateSelection(
        Selection.single(path: [0], startOffset: 0),
      );

      if (Platform.isWindows || Platform.isLinux) {
        await editor.pressLogicKey(
          key: LogicalKeyboardKey.backspace,
          isControlPressed: true,
        );
      } else {
        await editor.pressLogicKey(
          key: LogicalKeyboardKey.backspace,
          isAltPressed: true,
        );
      }

      //fetching all the text that is still on the editor.
      var nodes =
          editor.editorState.service.selectionService.currentSelectedNodes;
      var textNode = nodes.whereType<TextNode>().first;

      //nothing happens when there is no words to the left of the cursor
      expect(textNode.toPlainText(), text);

      await editor.updateSelection(
        Selection.single(path: [0], startOffset: 14),
      );
      //Welcome to App|flowy 😁

      if (Platform.isWindows || Platform.isLinux) {
        await editor.pressLogicKey(
          key: LogicalKeyboardKey.backspace,
          isControlPressed: true,
        );
      } else {
        await editor.pressLogicKey(
          key: LogicalKeyboardKey.backspace,
          isAltPressed: true,
        );
      }

      //fetching all the text that is still on the editor.
      nodes = editor.editorState.service.selectionService.currentSelectedNodes;
      textNode = nodes.whereType<TextNode>().first;

      const expectedText = 'Welcome to flowy 😁';
      expect(textNode.toPlainText(), expectedText);
    });

    testWidgets('Removes space and word after ctrl + backspace',
        (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor..insertTextNode(text);

      await editor.startTesting();

      await editor.updateSelection(
        Selection.single(path: [0], startOffset: 11),
      );
      //Welcome to |Appflowy 😁

      if (Platform.isWindows || Platform.isLinux) {
        await editor.pressLogicKey(
          key: LogicalKeyboardKey.backspace,
          isControlPressed: true,
        );
      } else {
        await editor.pressLogicKey(
          key: LogicalKeyboardKey.backspace,
          isAltPressed: true,
        );
      }

      //fetching all the text that is still on the editor.
      final nodes =
          editor.editorState.service.selectionService.currentSelectedNodes;
      final textNode = nodes.whereType<TextNode>().first;

      const expectedText = 'Welcome Appflowy 😁';
      expect(textNode.toPlainText(), expectedText);
    });

    testWidgets('ctrl + backspace works properly with only single whitespace',
        (tester) async {
      //edge case that checks if pressing ctrl+backspace on null value
      //after removing a whitespace, does not throw an exception.
      const text = ' ';
      final editor = tester.editor..insertTextNode(text);

      await editor.startTesting();

      await editor.updateSelection(
        Selection.single(path: [0], startOffset: text.length),
      );
      // |

      if (Platform.isWindows || Platform.isLinux) {
        await editor.pressLogicKey(
          key: LogicalKeyboardKey.backspace,
          isControlPressed: true,
        );
      } else {
        await editor.pressLogicKey(
          key: LogicalKeyboardKey.backspace,
          isAltPressed: true,
        );
      }

      //fetching all the text that is still on the editor.
      final nodes =
          editor.editorState.service.selectionService.currentSelectedNodes;
      final textNode = nodes.whereType<TextNode>().first;

      expect(textNode.toPlainText().isEmpty, true);
    });

    testWidgets('ctrl + alt + backspace works properly and deletes a sentence',
        (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor
        ..insertTextNode(text)
        ..insertTextNode(text)
        ..insertTextNode(text);

      await editor.startTesting();
      await editor.updateSelection(
        Selection.single(path: [0], startOffset: text.length),
      );
      //Welcome to Appflowy 😁|

      if (Platform.isWindows || Platform.isLinux) {
        await editor.pressLogicKey(
          key: LogicalKeyboardKey.backspace,
          isControlPressed: true,
          isAltPressed: true,
        );
      } else {
        await editor.pressLogicKey(
          key: LogicalKeyboardKey.backspace,
          isMetaPressed: true,
        );
      }

      //fetching all the text that is still on the editor.
      final nodes =
          editor.editorState.service.selectionService.currentSelectedNodes;
      final textNode = nodes.whereType<TextNode>().first;

      expect(textNode.toPlainText().isEmpty, true);
    });

    testWidgets('ctrl + alt + backspace works in the middle of a word',
        (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor..insertTextNode(text);

      await editor.startTesting();
      await editor.updateSelection(
        Selection.single(path: [0], startOffset: 14),
      );
      //Welcome to App|flowy 😁

      if (Platform.isWindows || Platform.isLinux) {
        await editor.pressLogicKey(
          key: LogicalKeyboardKey.backspace,
          isControlPressed: true,
          isAltPressed: true,
        );
      } else {
        await editor.pressLogicKey(
          key: LogicalKeyboardKey.backspace,
          isMetaPressed: true,
        );
      }

      //fetching all the text that is still on the editor.
      final nodes =
          editor.editorState.service.selectionService.currentSelectedNodes;
      final textNode = nodes.whereType<TextNode>().first;

      const expectedText = 'flowy 😁';
      expect(textNode.toPlainText(), expectedText);
    });
  });
}
