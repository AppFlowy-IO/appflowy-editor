import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../infra/testable_editor.dart';

const text = 'Welcome to AppFlowy Editor 🔥!';

void main() async {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('paste_command_test.dart paste_plaintext', () {
    testWidgets('works with formatted text', (tester) async {
      final editor = tester.editor..addParagraph(initialText: text);
      await editor.startTesting();

      await _applyFormatting(
        editor,
        BuiltInAttributeKey.underline,
        LogicalKeyboardKey.keyU,
      );

      await _applyFormatting(
        editor,
        BuiltInAttributeKey.italic,
        LogicalKeyboardKey.keyI,
      );

      await _applyFormatting(
        editor,
        BuiltInAttributeKey.bold,
        LogicalKeyboardKey.keyB,
      );
      await tester.pumpAndSettle();

      final selection = Selection.single(
        path: [0],
        startOffset: 0,
        endOffset: 7,
      );

      await editor.updateSelection(selection);
      await editor.pressKey(
        key: LogicalKeyboardKey.keyC,
        isMetaPressed: Platform.isMacOS,
        isControlPressed: Platform.isWindows || Platform.isLinux,
      );

      await editor.updateSelection(selection);

      await editor.pressKey(
        key: LogicalKeyboardKey.keyV,
        isShiftPressed: true,
        isMetaPressed: Platform.isMacOS,
        isControlPressed: Platform.isWindows || Platform.isLinux,
      );

      await editor.updateSelection(selection);
      final node = editor.nodeAtPath([0]);

      _checkSelectionNotFormatted(
        node!,
        selection,
        BuiltInAttributeKey.bold,
      );

      _checkSelectionNotFormatted(
        node,
        selection,
        BuiltInAttributeKey.underline,
      );

      _checkSelectionNotFormatted(
        node,
        selection,
        BuiltInAttributeKey.italic,
      );

      await editor.dispose();
    });
  });
}

Future<void> _applyFormatting(
  TestableEditor editor,
  String matchStyle,
  LogicalKeyboardKey key,
) async {
  final selection = Selection.single(
    path: [0],
    startOffset: 0,
    endOffset: 7,
  );
  await editor.updateSelection(selection);
  await editor.pressKey(
    key: key,
    isMetaPressed: Platform.isMacOS,
    isControlPressed: Platform.isWindows || Platform.isLinux,
  );
  final node = editor.nodeAtPath([0]);

  expect(
    node!.allSatisfyInSelection(selection, (delta) {
      return delta.whereType<TextInsert>().every(
            (el) => el.attributes?[matchStyle] == true,
          );
    }),
    true,
  );
}

void _checkSelectionNotFormatted(
  Node node,
  Selection selection,
  String matchStyle,
) {
  expect(
    node.allSatisfyInSelection(selection, (delta) {
      return delta.whereType<TextInsert>().every(
            (el) => el.attributes?[matchStyle] != true,
          );
    }),
    true,
  );
}
