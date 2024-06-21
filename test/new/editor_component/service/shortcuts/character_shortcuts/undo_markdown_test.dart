import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:appflowy_editor/appflowy_editor.dart';

import '../../../../infra/testable_editor.dart';

void main() async {
  group('undo_markdown_test.dart', () {
    testWidgets('single character markdown shortcut then undo', (tester) async {
      const helloWorld = "_Hello world_";

      final editor = tester.editor..addEmptyParagraph();
      await editor.startTesting();

      await editor.updateSelection(Selection.collapsed(Position(path: [0])));
      await editor.ime.typeText('_Hello world');
      await editor.ime.typeText('_');

      Delta delta = editor.nodeAtPath([0])!.delta!;
      expect(delta.length, 'Hello world'.length);
      expect(delta.first.attributes![AppFlowyRichTextKeys.italic], true);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyZ);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyZ);

      delta = editor.nodeAtPath([0])!.delta!;
      expect(delta.length, helloWorld.length);
      expect(delta.toPlainText(), helloWorld);
      expect(delta.first.attributes?[AppFlowyRichTextKeys.italic], null);

      await editor.dispose();
    });

    testWidgets('multi character markdown shortcut then undo', (tester) async {
      const helloWorld = "__Hello world__";

      final editor = tester.editor..addEmptyParagraph();
      await editor.startTesting();

      await editor.updateSelection(Selection.collapsed(Position(path: [0])));
      await editor.ime.typeText('__Hello world_');
      await editor.ime.typeText('_');

      Delta delta = editor.nodeAtPath([0])!.delta!;
      expect(delta.length, 'Hello world'.length);
      expect(delta.first.attributes![AppFlowyRichTextKeys.bold], true);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.control);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyZ);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.control);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyZ);

      delta = editor.nodeAtPath([0])!.delta!;
      expect(delta.length, helloWorld.length);
      expect(delta.toPlainText(), helloWorld);
      expect(delta.first.attributes?[AppFlowyRichTextKeys.italic], null);

      await editor.dispose();
    });
  });
}
