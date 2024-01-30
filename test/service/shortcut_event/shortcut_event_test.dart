import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../new/infra/testable_editor.dart';

void main() async {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('shortcut_event.dart', () {
    test('redefine shortcut event command', () {
      final shortcutEvent = CommandShortcutEvent(
        key: 'Sample',
        getDescription: () => 'Sample',
        command: 'cmd+shift+alt+ctrl+a',
        handler: (editorState) {
          return KeyEventResult.handled;
        },
      );

      shortcutEvent.updateCommand(command: 'cmd+shift+alt+ctrl+b');
      expect(shortcutEvent.keybindings.length, 1);
      expect(shortcutEvent.keybindings.first.isMetaPressed, true);
      expect(shortcutEvent.keybindings.first.isShiftPressed, true);
      expect(shortcutEvent.keybindings.first.isAltPressed, true);
      expect(shortcutEvent.keybindings.first.isControlPressed, true);
      expect(shortcutEvent.keybindings.first.keyLabel, 'b');
    });

    testWidgets('redefine move cursor begin command', (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor..addParagraphs(2, initialText: text);

      await editor.startTesting();

      final selection = Selection.single(path: [1], startOffset: text.length);
      await editor.updateSelection(selection);

      await editor.pressKey(
        key: Platform.isMacOS
            ? LogicalKeyboardKey.arrowLeft
            : LogicalKeyboardKey.home,
        isMetaPressed: Platform.isMacOS,
      );

      expect(
        editor.selection,
        Selection.single(path: [1], startOffset: 0),
      );

      await editor.updateSelection(selection);

      const newCommand = 'alt+arrow left';
      moveCursorToBeginCommand.updateCommand(
        windowsCommand: newCommand,
        linuxCommand: newCommand,
        macOSCommand: newCommand,
      );

      await editor.pressKey(
        key: LogicalKeyboardKey.arrowLeft,
        isAltPressed: true,
      );

      expect(
        editor.selection,
        Selection.single(path: [1], startOffset: 0),
      );

      await editor.dispose();
    });

    testWidgets('redefine move cursor end command', (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor..addParagraphs(2, initialText: text);

      await editor.startTesting();

      final selection = Selection.single(path: [1], startOffset: 0);
      await editor.updateSelection(selection);

      await editor.pressKey(
        key: Platform.isMacOS
            ? LogicalKeyboardKey.arrowRight
            : LogicalKeyboardKey.end,
        isMetaPressed: Platform.isMacOS,
      );

      expect(
        editor.selection,
        Selection.single(path: [1], startOffset: text.length),
      );

      await editor.updateSelection(selection);

      const newCommand = 'alt+arrow right';
      moveCursorToEndCommand.updateCommand(
        windowsCommand: newCommand,
        linuxCommand: newCommand,
        macOSCommand: newCommand,
      );

      await editor.pressKey(
        key: LogicalKeyboardKey.arrowRight,
        isAltPressed: true,
      );

      expect(
        editor.selection,
        Selection.single(path: [1], startOffset: text.length),
      );

      await editor.dispose();
    });
  });
}
