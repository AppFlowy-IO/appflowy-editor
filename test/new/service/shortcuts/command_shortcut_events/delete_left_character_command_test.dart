import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../infra/testable_editor.dart';

// single | means the cursor
// double | means the selection
void main() async {
  group('deletion of a character while holding down shift key - widget test',
      () {
    const text = 'Welcome to AppFlowy Editor 🔥!';
    const List<LogicalKeyboardKey> keys = [
      LogicalKeyboardKey.shift,
      LogicalKeyboardKey.backspace,
    ];
    // Before
    // |Welcome| to AppFlowy Editor 🔥!
    // After
    // | to AppFlowy Editor 🔥!
    testWidgets('Delete the collapsed selection', (tester) async {
      final editor = tester.editor
        ..addParagraph(
          initialText: text,
        );
      await editor.startTesting();

      // Welcome| to AppFlowy Editor 🔥!
      const welcome = 'Welcome';
      final selection = Selection.single(
        path: [0],
        startOffset: 0,
        endOffset: welcome.length,
      );
      await editor.updateSelection(selection);

      for (final LogicalKeyboardKey key in keys) {
        await simulateKeyDownEvent(key);
        await tester.pumpAndSettle();
      }

      // the first node should be deleted.
      expect(
        editor.nodeAtPath([0])?.delta?.toPlainText(),
        text.substring(welcome.length),
      );

      await editor.dispose();
    });

    // Before
    // # Welcome to |AppFlowy Editor 🔥!
    // * Welcome to |AppFlowy Editor 🔥!
    //  * Welcome to AppFlowy Editor 🔥!
    // After
    // # Welcome to AppFlowy Editor 🔥!
    // * Welcome to AppFlowy Editor 🔥!
    testWidgets(
        'Delete the collapsed selection and the first node can\'t have children',
        (tester) async {
      final delta = Delta()..insert(text);
      final editor = tester.editor
        ..addNode(headingNode(level: 1, delta: delta))
        ..addNode(
          bulletedListNode(
            delta: delta,
            children: [bulletedListNode(delta: delta)],
          ),
        );

      await editor.startTesting();

      const welcome = 'Welcome to ';
      final selection = Selection(
        start: Position(
          path: [0],
          offset: welcome.length,
        ),
        end: Position(
          path: [1],
          offset: welcome.length,
        ),
      );
      await editor.updateSelection(selection);

      for (final LogicalKeyboardKey key in keys) {
        await simulateKeyDownEvent(key);
        await tester.pumpAndSettle();
      }

      expect(
        editor.nodeAtPath([0])?.delta?.toPlainText(),
        text,
      );

      final bulletedNode = editor.nodeAtPath([1])!;
      expect(bulletedNode.type, BulletedListBlockKeys.type);
      expect(bulletedNode.delta!.toPlainText(), text);

      await editor.dispose();
    });

    // Before
    // * Welcome to |AppFlowy Editor 🔥!
    // * Welcome to |AppFlowy Editor 🔥!
    //  * Welcome to AppFlowy Editor 🔥!
    // After
    // # Welcome to AppFlowy Editor 🔥!
    // * Welcome to AppFlowy Editor 🔥!
    testWidgets(
        'Delete the collapsed selection and the first node can have children',
        (tester) async {
      final delta = Delta()..insert(text);
      final editor = tester.editor
        ..addNode(bulletedListNode(delta: delta))
        ..addNode(
          bulletedListNode(
            delta: delta,
            children: [bulletedListNode(delta: delta)],
          ),
        );

      await editor.startTesting();

      const welcome = 'Welcome to ';
      final selection = Selection(
        start: Position(
          path: [0],
          offset: welcome.length,
        ),
        end: Position(
          path: [1],
          offset: welcome.length,
        ),
      );
      await editor.updateSelection(selection);

      for (final LogicalKeyboardKey key in keys) {
        await simulateKeyDownEvent(key);
        await tester.pumpAndSettle();
      }

      expect(
        editor.nodeAtPath([0])?.delta?.toPlainText(),
        text,
      );

      final bulletedNode = editor.nodeAtPath([0, 0])!;
      expect(bulletedNode.type, BulletedListBlockKeys.type);
      expect(bulletedNode.delta!.toPlainText(), text);

      await editor.dispose();
    });

    // Before
    // Welcome to AppFlowy Editor 🔥!
    // |---|
    // Welcome to AppFlowy Editor 🔥!
    // After
    // Welcome to AppFlowy Editor 🔥!
    // |Welcome to AppFlowy Editor 🔥!
    testWidgets('Delete the non-text node, such as divider', (tester) async {
      final editor = tester.editor
        ..addParagraph(initialText: text)
        ..addNode(dividerNode())
        ..addParagraph(initialText: text);

      await editor.startTesting();

      final selection = Selection.single(
        path: [1],
        startOffset: 0,
        endOffset: 1,
      );
      await editor.updateSelection(selection);

      for (final LogicalKeyboardKey key in keys) {
        await simulateKeyDownEvent(key);
        await tester.pumpAndSettle();
      }

      expect(
        editor.nodeAtPath([1])?.delta?.toPlainText(),
        text,
      );
      expect(
        editor.selection,
        Selection.collapsed(Position(path: [1])),
      );

      await editor.dispose();
    });

    testWidgets("clear text but keep the old direction", (tester) async {
      final editor = tester.editor
        ..addNode(
          paragraphNode(
            text: 'Hello',
            textDirection: blockComponentTextDirectionLTR,
          ),
        )
        ..addNode(
          paragraphNode(
            text: 'س',
            textDirection: blockComponentTextDirectionAuto,
          ),
        );
      await editor.startTesting();

      Node node = editor.nodeAtPath([1])!;
      expect(
        node.selectable?.textDirection().name,
        blockComponentTextDirectionRTL,
      );

      final selection = Selection.collapsed(
        Position(path: [1], offset: 1),
      );
      await editor.updateSelection(selection);

      for (final LogicalKeyboardKey key in keys) {
        await simulateKeyDownEvent(key);
        await tester.pumpAndSettle();
      }

      node = editor.nodeAtPath([1])!;
      expect(
        node.delta?.toPlainText().isEmpty,
        true,
      );
      expect(
        node.selectable?.textDirection().name,
        blockComponentTextDirectionRTL,
      );

      await editor.dispose();
    });
  });
}
