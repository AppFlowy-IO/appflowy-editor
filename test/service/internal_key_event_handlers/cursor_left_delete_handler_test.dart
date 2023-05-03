import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../new/infra/testable_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('cursor_left_delete_handler.dart', () {
    testWidgets('Presses ctrl + backspace to delete a word', (tester) async {
      List<String> words = ["Welcome", " ", "to", " ", "Appflowy", " ", "😁"];
      final text = words.join();
      final editor = tester.editor..addParagraph(initialText: text);

      await editor.startTesting();
      await editor.updateSelection(
        Selection.single(path: [0], startOffset: text.length),
      );

      await editor.pressKey(
        key: LogicalKeyboardKey.backspace,
        isControlPressed: Platform.isWindows || Platform.isLinux,
        isAltPressed: Platform.isMacOS,
      );

      //fetching all the text that is still on the editor.
      final selection = editor.selection!;
      assert(selection.isSingle, true);
      var node = editor.nodeAtPath(selection.end.path)!;

      words.removeLast();
      //expected: Welcome_to_Appflowy_
      //here _ actually represents ' '
      expect(node.delta!.toPlainText(), words.join());

      await editor.pressKey(
        key: LogicalKeyboardKey.backspace,
        isControlPressed: Platform.isWindows || Platform.isLinux,
        isAltPressed: Platform.isMacOS,
      );

      //fetching all the text that is still on the editor.
      node = editor.nodeAtPath(selection.end.path)!;

      //removes the whitespace
      words.removeLast();
      words.removeLast();
      //expected is: Welcome_to_
      expect(node.delta!.toPlainText(), words.join());

      //we divide words.length by 2 becuase we know half words are whitespaces.
      for (var i = 0; i < words.length / 2; i++) {
        await editor.pressKey(
          key: LogicalKeyboardKey.backspace,
          isControlPressed: Platform.isWindows || Platform.isLinux,
          isAltPressed: Platform.isMacOS,
        );
      }

      node = editor.nodeAtPath(selection.end.path)!;

      expect(node.delta!.toPlainText(), '');

      await editor.dispose();
    });

    testWidgets('ctrl+backspace in the middle of a word', (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor..addParagraph(initialText: text);

      await editor.startTesting();
      await editor.updateSelection(
        Selection.single(path: [0], startOffset: 0),
      );

      await editor.pressKey(
        key: LogicalKeyboardKey.backspace,
        isControlPressed: Platform.isWindows || Platform.isLinux,
        isAltPressed: Platform.isMacOS,
      );

      //fetching all the text that is still on the editor.
      final selection = editor.selection!;
      var node = editor.editorState.getNodeAtPath(selection.end.path)!;

      //nothing happens when there is no words to the left of the cursor
      expect(node.delta!.toPlainText(), text);

      await editor.updateSelection(
        Selection.single(path: [0], startOffset: 14),
      );
      //Welcome to App|flowy 😁

      await editor.pressKey(
        key: LogicalKeyboardKey.backspace,
        isControlPressed: Platform.isWindows || Platform.isLinux,
        isAltPressed: Platform.isMacOS,
      );

      //fetching all the text that is still on the editor.
      node = editor.editorState.getNodeAtPath(selection.end.path)!;

      const expectedText = 'Welcome to flowy 😁';
      expect(node.delta!.toPlainText(), expectedText);

      await editor.dispose();
    });

    testWidgets('Removes space and word after ctrl + backspace',
        (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor..addParagraph(initialText: text);

      await editor.startTesting();

      // Welcome to |Appflowy 😁
      await editor.updateSelection(
        Selection.single(path: [0], startOffset: 11),
      );

      await editor.pressKey(
        key: LogicalKeyboardKey.backspace,
        isControlPressed: Platform.isWindows || Platform.isLinux,
        isAltPressed: Platform.isMacOS,
      );

      //fetching all the text that is still on the editor.
      final selection = editor.selection!;
      final node = editor.editorState.getNodeAtPath(selection.end.path)!;

      const expectedText = 'Welcome Appflowy 😁';
      expect(node.delta!.toPlainText(), expectedText);

      await editor.dispose();
    });

    testWidgets('ctrl + backspace works properly with only single whitespace',
        (tester) async {
      //edge case that checks if pressing ctrl+backspace on null value
      //after removing a whitespace, does not throw an exception.
      const text = ' ';
      final editor = tester.editor..addParagraph(initialText: text);

      await editor.startTesting();

      await editor.updateSelection(
        Selection.single(path: [0], startOffset: text.length),
      );
      // |

      await editor.pressKey(
        key: LogicalKeyboardKey.backspace,
        isControlPressed: Platform.isWindows || Platform.isLinux,
        isAltPressed: Platform.isMacOS,
      );

      //fetching all the text that is still on the editor.
      final selection = editor.selection!;
      final node = editor.editorState.getNodeAtPath(selection.end.path)!;

      expect(node.delta!.toPlainText().isEmpty, true);

      await editor.dispose();
    });

    testWidgets('ctrl + alt + backspace works properly and deletes a sentence',
        (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor..addParagraphs(3, initialText: text);

      await editor.startTesting();
      await editor.updateSelection(
        Selection.single(path: [0], startOffset: text.length),
      );
      //Welcome to Appflowy 😁|

      await editor.pressKey(
        key: LogicalKeyboardKey.backspace,
        isControlPressed: Platform.isWindows || Platform.isLinux,
        isAltPressed: Platform.isWindows || Platform.isLinux,
        isMetaPressed: Platform.isMacOS,
      );

      //fetching all the text that is still on the editor.
      final selection = editor.selection!;
      final node = editor.editorState.getNodeAtPath(selection.end.path)!;

      expect(node.delta!.toPlainText().isEmpty, true);

      await editor.dispose();
    });

    testWidgets('ctrl + alt + backspace works in the middle of a word',
        (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor..addParagraph(initialText: text);

      await editor.startTesting();
      await editor.updateSelection(
        Selection.single(path: [0], startOffset: 14),
      );
      //Welcome to App|flowy 😁

      await editor.pressKey(
        key: LogicalKeyboardKey.backspace,
        isControlPressed: Platform.isWindows || Platform.isLinux,
        isAltPressed: Platform.isWindows || Platform.isLinux,
        isMetaPressed: Platform.isMacOS,
      );

      //fetching all the text that is still on the editor.
      final selection = editor.selection!;
      final node = editor.editorState.getNodeAtPath(selection.end.path)!;

      const expectedText = 'flowy 😁';
      expect(node.delta!.toPlainText(), expectedText);

      await editor.dispose();
    });
  });
}
