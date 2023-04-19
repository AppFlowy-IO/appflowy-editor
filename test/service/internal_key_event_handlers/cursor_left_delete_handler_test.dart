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
      var selection = Selection.single(path: [0], startOffset: text.length);
      await editor.updateSelection(selection);

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
      var newText = textNode.toPlainText();

      words.removeLast();
      //expected: Welcome_to_Appflowy_
      //here _ actually represents ' '
      expect(newText, words.join());

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

      newText = textNode.toPlainText();

      //removes the whitespace
      words.removeLast();
      words.removeLast();
      //expected is: Welcome_to_
      expect(newText, words.join());

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

      newText = textNode.toPlainText();

      expect(newText, '');
    });

    testWidgets('ctrl+backspace in the middle of a word', (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor..insertTextNode(text);

      await editor.startTesting();
      var selection = Selection.single(path: [0], startOffset: 0);
      await editor.updateSelection(selection);

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
      var newText = textNode.toPlainText();

      //nothing happens
      expect(newText, text);

      selection = Selection.single(path: [0], startOffset: 14);
      await editor.updateSelection(selection);
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
      newText = textNode.toPlainText();

      const expectedText = 'Welcome to flowy 😁';
      expect(newText, expectedText);
    });

    testWidgets('Removes space and word after ctrl + backspace',
        (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor..insertTextNode(text);

      await editor.startTesting();

      //fetching all the text that is still on the editor.
      var nodes =
          editor.editorState.service.selectionService.currentSelectedNodes;

      final selection = Selection.single(path: [0], startOffset: 11);
      await editor.updateSelection(selection);
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
      nodes = editor.editorState.service.selectionService.currentSelectedNodes;
      final textNode = nodes.whereType<TextNode>().first;
      final newText = textNode.toPlainText();

      const expectedText = 'Welcome Appflowy 😁';
      expect(newText, expectedText);
    });
  });
}
