import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../new/infra/testable_editor.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('arrow_keys_handler.dart', () {
    testWidgets('Presses arrow right key, move the cursor from left to right',
        (tester) async {
      const text = 'Welcome to Appflowy 😁';
      final editor = tester.editor..addParagraphs(2, initialText: text);
      await editor.startTesting();

      await editor.updateSelection(
        Selection.single(path: [0], startOffset: 0),
      );

      for (var i = 0; i < text.length; i++) {
        await editor.pressKey(key: LogicalKeyboardKey.arrowRight);

        if (i == text.length - 1) {
          // Wrap to next node if the cursor is at the end of the current node.
          expect(
            editor.selection,
            Selection.single(
              path: [1],
              startOffset: 0,
            ),
          );
        } else {
          final delta = editor.nodeAtPath([0])!.delta!;
          expect(
            editor.selection,
            Selection.single(
              path: [0],
              startOffset: delta.nextRunePosition(i),
            ),
          );
        }
      }

      await editor.dispose();
    });
  });

  testWidgets('Cursor up/down', (tester) async {
    const text1 = 'Welcome';
    const text2 = 'Welcome to AppFlowy';
    final editor = tester.editor
      ..addParagraph(initialText: text1)
      ..addParagraph(initialText: text2);
    await editor.startTesting();

    await editor.updateSelection(
      Selection.single(path: [1], startOffset: text2.length),
    );

    await editor.pressKey(key: LogicalKeyboardKey.arrowUp);
    expect(
      editor.selection,
      Selection.single(path: [0], startOffset: text1.length),
    );

    await editor.pressKey(key: LogicalKeyboardKey.arrowDown);
    expect(
      editor.selection,
      Selection.single(path: [1], startOffset: text1.length),
    );

    await editor.dispose();
  });

  testWidgets('Cursor top/bottom select', (tester) async {
    const text = 'Welcome to Appflowy';
    final editor = tester.editor..addParagraphs(3, initialText: text);
    await editor.startTesting();

    Future<void> select(bool isTop) async {
      return editor.pressKey(
        key: isTop ? LogicalKeyboardKey.arrowUp : LogicalKeyboardKey.arrowDown,
        isMetaPressed: Platform.isMacOS,
        isControlPressed: Platform.isWindows || Platform.isLinux,
        isShiftPressed: true,
      );
    }

    final selection = Selection.collapsed(Position(path: [1], offset: 7));

    // Welcome| to Appflowy
    await editor.updateSelection(
      selection,
    );

    await select(true);

    expect(
      editor.selection,
      selection.copyWith(
        end: Position(path: [0], offset: 0),
      ),
    );

    await select(false);
    expect(
      editor.selection,
      selection.copyWith(
        end: Position(path: [2], offset: 19),
      ),
    );

    await editor.dispose();
  });

  testWidgets('''move the cursor one word right
  MacOS: presses alt + arrow right key, 
  Windows & Linux: presses ctrl + arrow right key, 
  ''', (tester) async {
    const text = 'Welcome to Appflowy';
    final editor = tester.editor..addParagraphs(2, initialText: text);
    await editor.startTesting();

    final selection = Selection.collapsed(Position(path: [0]));
    await editor.updateSelection(
      selection,
    );

    await _pressShortcutToNavigateAroundWord(editor);

    expect(
      editor.selection,
      Selection.collapsed(Position(path: [0], offset: 'Welcome'.length)),
    );

    await editor.pressKey(
      key: LogicalKeyboardKey.arrowRight,
    );
    await _pressShortcutToNavigateAroundWord(editor);

    expect(
      editor.selection,
      Selection.collapsed(Position(path: [0], offset: 'Welcome to'.length)),
    );

    await editor.pressKey(
      key: LogicalKeyboardKey.arrowRight,
    );
    await _pressShortcutToNavigateAroundWord(editor);

    expect(
      editor.selection,
      Selection.collapsed(Position(path: [0], offset: text.length)),
    );

    await editor.dispose();
  });

  testWidgets('''move the cursor one word left
  MacOS: presses alt + arrow left key, 
  Windows & Linux: presses ctrl + arrow left key, 
  ''', (tester) async {
    const text = 'Welcome to Appflowy';
    final editor = tester.editor..addParagraphs(2, initialText: text);
    await editor.startTesting();

    final selection =
        Selection.collapsed(Position(path: [0], offset: text.length));
    await editor.updateSelection(
      selection,
    );

    await _pressShortcutToNavigateAroundWord(editor, toRight: false);

    expect(
      editor.selection,
      Selection.collapsed(Position(path: [0], offset: 11)),
    );

    await editor.pressKey(
      key: LogicalKeyboardKey.arrowLeft,
    );
    await _pressShortcutToNavigateAroundWord(editor, toRight: false);

    expect(
      editor.selection,
      Selection.collapsed(Position(path: [0], offset: 8)),
    );

    await editor.pressKey(
      key: LogicalKeyboardKey.arrowLeft,
    );
    await _pressShortcutToNavigateAroundWord(editor, toRight: false);

    expect(
      editor.selection,
      Selection.collapsed(Position(path: [0])),
    );

    await editor.dispose();
  });

  testWidgets(
      'Presses arrow left/right key since selection is not collapsed and backward',
      (tester) async {
    await _testPressArrowKeyInNotCollapsedSelection(tester, true);
  });

  testWidgets(
      'Presses arrow left/right key since selection is not collapsed and forward',
      (tester) async {
    await _testPressArrowKeyInNotCollapsedSelection(tester, false);
  });

  testWidgets('Presses arrow left/right + shift in collapsed selection',
      (tester) async {
    const text = 'Welcome to Appflowy';
    final editor = tester.editor..addParagraphs(2, initialText: text);
    await editor.startTesting();

    const offset = 8;
    final selection = Selection.single(path: [1], startOffset: offset);
    await editor.updateSelection(selection);

    for (var i = offset - 1; i >= 0; i--) {
      await editor.pressKey(
        key: LogicalKeyboardKey.arrowLeft,
        isShiftPressed: true,
      );
      expect(
        editor.selection,
        selection.copyWith(
          end: Position(path: [1], offset: i),
        ),
      );
    }
    for (var i = text.length; i >= 0; i--) {
      await editor.pressKey(
        key: LogicalKeyboardKey.arrowLeft,
        isShiftPressed: true,
      );
      expect(
        editor.selection,
        selection.copyWith(
          end: Position(path: [0], offset: i),
        ),
      );
    }
    for (var i = 1; i <= text.length; i++) {
      await editor.pressKey(
        key: LogicalKeyboardKey.arrowRight,
        isShiftPressed: true,
      );
      expect(
        editor.selection,
        selection.copyWith(
          end: Position(path: [0], offset: i),
        ),
      );
    }
    for (var i = 0; i < text.length; i++) {
      await editor.pressKey(
        key: LogicalKeyboardKey.arrowRight,
        isShiftPressed: true,
      );
      expect(
        editor.selection,
        selection.copyWith(
          end: Position(path: [1], offset: i),
        ),
      );
    }

    await editor.dispose();
  });

  testWidgets(
      'Presses arrow left/right + shift in not collapsed and backward selection',
      (tester) async {
    const text = 'Welcome to Appflowy';
    final editor = tester.editor..addParagraphs(2, initialText: text);
    await editor.startTesting();

    const start = 8;
    const end = 12;
    final selection = Selection.single(
      path: [0],
      startOffset: start,
      endOffset: end,
    );
    await editor.updateSelection(selection);
    for (var i = end + 1; i <= text.length; i++) {
      await editor.pressKey(
        key: LogicalKeyboardKey.arrowRight,
        isShiftPressed: true,
      );
      expect(
        editor.selection,
        selection.copyWith(
          end: Position(path: [0], offset: i),
        ),
      );
    }
    for (var i = text.length - 1; i >= 0; i--) {
      await editor.pressKey(
        key: LogicalKeyboardKey.arrowLeft,
        isShiftPressed: true,
      );
      expect(
        editor.selection,
        selection.copyWith(
          end: Position(path: [0], offset: i),
        ),
      );
    }

    await editor.dispose();
  });

  testWidgets(
      'Presses arrow left/right + command in not collapsed and forward selection',
      (tester) async {
    const text = 'Welcome to Appflowy';
    final editor = tester.editor..addParagraphs(2, initialText: text);
    await editor.startTesting();

    const start = 12;
    const end = 8;
    final selection = Selection.single(
      path: [0],
      startOffset: start,
      endOffset: end,
    );
    await editor.updateSelection(selection);
    for (var i = end - 1; i >= 0; i--) {
      await editor.pressKey(
        key: LogicalKeyboardKey.arrowLeft,
        isShiftPressed: true,
      );
      expect(
        editor.selection,
        selection.copyWith(
          end: Position(path: [0], offset: i),
        ),
      );
    }
    for (var i = 1; i <= text.length; i++) {
      await editor.pressKey(
        key: LogicalKeyboardKey.arrowRight,
        isShiftPressed: true,
      );
      expect(
        editor.selection,
        selection.copyWith(
          end: Position(path: [0], offset: i),
        ),
      );
    }

    await editor.dispose();
  });

  testWidgets('Presses arrow left/right/up/down + meta in collapsed selection',
      (tester) async {
    await _testPressArrowKeyWithMetaInSelection(tester, true, false);
  });

  testWidgets(
      'Presses arrow left/right/up/down + meta in not collapsed and backward selection',
      (tester) async {
    await _testPressArrowKeyWithMetaInSelection(tester, false, true);
  });

  testWidgets(
      'Presses arrow left/right/up/down + meta in not collapsed and forward selection',
      (tester) async {
    await _testPressArrowKeyWithMetaInSelection(tester, false, false);
  });

  testWidgets('Presses arrow up/down + shift in not collapsed selection',
      (tester) async {
    const text = 'Welcome to Appflowy 😁';
    final editor = tester.editor
      ..addParagraphs(2, initialText: text)
      ..addEmptyParagraph()
      ..addParagraph(initialText: text)
      ..addEmptyParagraph()
      ..addParagraphs(2, initialText: text);
    await editor.startTesting();
    final selection = Selection.single(path: [3], startOffset: 8);
    await editor.updateSelection(selection);
    for (int i = 0; i < 3; i++) {
      await editor.pressKey(
        key: LogicalKeyboardKey.arrowUp,
        isShiftPressed: true,
      );
    }
    expect(
      editor.selection,
      selection.copyWith(
        end: Position(path: [0], offset: 0),
      ),
    );
    for (int i = 0; i < 7; i++) {
      await editor.pressKey(
        key: LogicalKeyboardKey.arrowDown,
        isShiftPressed: true,
      );
    }
    expect(
      editor.selection,
      selection.copyWith(
        end: Position(path: [6], offset: 0),
      ),
    );
    for (int i = 0; i < 3; i++) {
      await editor.pressKey(
        key: LogicalKeyboardKey.arrowUp,
        isShiftPressed: true,
      );
    }
    expect(
      editor.selection,
      selection.copyWith(
        end: Position(path: [3], offset: 0),
      ),
    );

    await editor.dispose();
  });

  //Before:
  //Welcome |to Appflowy 😁
  //Welcome to Appflowy 😁
  //After On Mac
  //Welcome |to Appflowy 😁
  //Welcome to Appflowy 😁|
  //expands the selection to include till end of line
  //After On Windows
  //Welcome |to Appflowy 😁
  //Welcome to| Appflowy 😁
  //expands the selection to include till end of next word
  testWidgets('Presses shift + arrow down and meta/ctrl + shift + right',
      (tester) async {
    const text = 'Welcome to Appflowy 😁';
    final editor = tester.editor..addParagraphs(2, initialText: text);
    await editor.startTesting();
    final selection = Selection.single(path: [0], startOffset: 8);
    await editor.updateSelection(selection);
    await editor.pressKey(
      key: LogicalKeyboardKey.arrowDown,
      isShiftPressed: true,
    );
    await editor.pressKey(
      key: LogicalKeyboardKey.arrowRight,
      isShiftPressed: true,
      isControlPressed: Platform.isWindows || Platform.isLinux,
      isMetaPressed: Platform.isMacOS,
    );
    if (Platform.isMacOS) {
      expect(
        editor.selection,
        selection.copyWith(
          end: Position(path: [1], offset: text.length),
        ),
      );
    } else {
      expect(
        editor.selection,
        selection.copyWith(
          end: Position(path: [1], offset: 'Welcome to'.length),
        ),
      );
    }
    await editor.dispose();
  });

  //Before:
  //Welcome to Appflowy 😁
  //Welcome |to Appflowy 😁
  //After On Mac
  //|Welcome to Appflowy 😁
  //Welcome |to Appflowy 😁
  //expands the selection to include till end of line
  //After On Windows
  //Welcome| to Appflowy 😁
  //Welcome |to Appflowy 😁
  //expands the selection to include till end of next word
  testWidgets('Presses shift + arrow up and meta/ctrl + shift + left',
      (tester) async {
    const text = 'Welcome to Appflowy 😁';
    final editor = tester.editor..addParagraphs(2, initialText: text);
    await editor.startTesting();
    final selection = Selection.single(path: [1], startOffset: 8);
    await editor.updateSelection(selection);
    await editor.pressKey(
      key: LogicalKeyboardKey.arrowUp,
      isShiftPressed: true,
    );
    await editor.pressKey(
      key: LogicalKeyboardKey.arrowLeft,
      isShiftPressed: true,
      isControlPressed: Platform.isWindows || Platform.isLinux,
      isMetaPressed: Platform.isMacOS,
    );
    if (Platform.isMacOS) {
      expect(
        editor.selection,
        selection.copyWith(
          end: Position(path: [0], offset: 0),
        ),
      );
    } else {
      expect(
        editor.selection,
        selection.copyWith(
          end: Position(path: [0], offset: 'Welcome'.length),
        ),
      );
    }
    await editor.dispose();
  });

  // press alt on MacOS to select a word
  // press ctrl on Windows and Linux to select a word
  testWidgets('Presses shift + alt/ctrl + arrow left to select a word',
      (tester) async {
    const text = 'Welcome to Appflowy 😁';
    final editor = tester.editor..addParagraphs(2, initialText: text);
    await editor.startTesting();
    final selection = Selection.single(path: [1], startOffset: 10);
    await editor.updateSelection(selection);
    await editor.pressKey(
      key: LogicalKeyboardKey.arrowLeft,
      isShiftPressed: true,
      isAltPressed: Platform.isMacOS,
      isControlPressed: Platform.isWindows || Platform.isLinux,
    );
    // <to>
    expect(
      editor.selection,
      selection.copyWith(
        end: Position(path: [1], offset: 8),
      ),
    );
    await editor.pressKey(
      key: LogicalKeyboardKey.arrowLeft,
      isShiftPressed: true,
      isAltPressed: Platform.isMacOS,
      isControlPressed: Platform.isWindows || Platform.isLinux,
    );
    // < to>
    expect(
      editor.selection,
      selection.copyWith(
        end: Position(path: [1], offset: 7),
      ),
    );
    await editor.pressKey(
      key: LogicalKeyboardKey.arrowLeft,
      isShiftPressed: true,
      isAltPressed: Platform.isMacOS,
      isControlPressed: Platform.isWindows || Platform.isLinux,
    );
    // <Welcome to>
    expect(
      editor.selection,
      selection.copyWith(
        end: Position(path: [1], offset: 0),
      ),
    );
    await editor.pressKey(
      key: LogicalKeyboardKey.arrowLeft,
      isShiftPressed: true,
      isAltPressed: Platform.isMacOS,
      isControlPressed: Platform.isWindows || Platform.isLinux,
    );
    // <😁>
    // <Welcome to>
    expect(
      editor.selection,
      selection.copyWith(
        end: Position(path: [0], offset: 22),
      ),
    );
    await editor.dispose();
  });

  // press alt on MacOS to select a word
  // press ctrl on Windows and Linux to select a word
  testWidgets('Presses shift + alt/ctrl + arrow right to select a word',
      (tester) async {
    const text = 'Welcome to Appflowy 😁';
    final editor = tester.editor..addParagraphs(2, initialText: text);
    await editor.startTesting();
    final selection = Selection.single(path: [0], startOffset: 10);
    await editor.updateSelection(selection);
    await editor.pressKey(
      key: LogicalKeyboardKey.arrowRight,
      isShiftPressed: true,
      isAltPressed: Platform.isMacOS,
      isControlPressed: Platform.isWindows || Platform.isLinux,
    );
    // < >
    expect(
      editor.selection,
      selection.copyWith(
        end: Position(path: [0], offset: 11),
      ),
    );
    await editor.pressKey(
      key: LogicalKeyboardKey.arrowRight,
      isShiftPressed: true,
      isAltPressed: Platform.isMacOS,
      isControlPressed: Platform.isWindows || Platform.isLinux,
    );
    // < Appflowy>
    expect(
      editor.selection,
      selection.copyWith(
        end: Position(path: [0], offset: 19),
      ),
    );
    await editor.pressKey(
      key: LogicalKeyboardKey.arrowRight,
      isShiftPressed: true,
      isAltPressed: Platform.isMacOS,
      isControlPressed: Platform.isWindows || Platform.isLinux,
    );
    await editor.pressKey(
      key: LogicalKeyboardKey.arrowRight,
      isShiftPressed: true,
      isAltPressed: Platform.isMacOS,
      isControlPressed: Platform.isWindows || Platform.isLinux,
    );
    // < Appflowy 😁>
    expect(
      editor.selection,
      selection.copyWith(
        end: Position(path: [0], offset: 22),
      ),
    );
    await editor.pressKey(
      key: LogicalKeyboardKey.arrowRight,
      isShiftPressed: true,
      isAltPressed: Platform.isMacOS,
      isControlPressed: Platform.isWindows || Platform.isLinux,
    );
    // < Appflowy 😁>
    // <>
    expect(
      editor.selection,
      selection.copyWith(
        end: Position(path: [1], offset: 0),
      ),
    );
    await editor.dispose();
  });
}

Future<void> _testPressArrowKeyWithMetaInSelection(
  WidgetTester tester,
  bool isSingle,
  bool isBackward,
) async {
  const text = 'Welcome to Appflowy';
  final editor = tester.editor..addParagraphs(2, initialText: text);
  await editor.startTesting();

  final initialSelection = Selection.single(path: [0], startOffset: 8);
  final selectionAtBeginning = Selection.single(path: [0], startOffset: 0);
  final selectionAtEnd = Selection.single(path: [0], startOffset: text.length);
  final selectionAtEndOfWelcome = Selection.single(path: [0], startOffset: 7);

  Selection selection;
  if (isSingle) {
    selection = initialSelection;
  } else {
    if (isBackward) {
      selection = Selection.single(
        path: [0],
        startOffset: 8,
        endOffset: text.length,
      );
    } else {
      selection = Selection.single(
        path: [0],
        startOffset: text.length,
        endOffset: 8,
      );
    }
  }

  await editor.updateSelection(selection);

  await editor.pressKey(
    key: LogicalKeyboardKey.arrowLeft,
    isControlPressed: Platform.isWindows || Platform.isLinux,
    isMetaPressed: Platform.isMacOS,
  );

  if (Platform.isMacOS) {
    expect(editor.selection, selectionAtBeginning);
  } else if (isSingle) {
    expect(editor.selection, selectionAtEndOfWelcome);
  } else {
    expect(editor.selection, initialSelection);
  }

  await editor.updateSelection(selectionAtBeginning);

  await editor.pressKey(
    key: LogicalKeyboardKey.arrowRight,
    isControlPressed: Platform.isWindows || Platform.isLinux,
    isMetaPressed: Platform.isMacOS,
  );

  if (Platform.isMacOS) {
    expect(editor.selection, selectionAtEnd);
  } else {
    expect(editor.selection, selectionAtEndOfWelcome);
  }

  await editor.updateSelection(selectionAtEnd);

  await editor.pressKey(
    key: LogicalKeyboardKey.arrowUp,
    isControlPressed: Platform.isWindows || Platform.isLinux,
    isMetaPressed: Platform.isMacOS,
  );

  expect(
    editor.selection,
    selectionAtBeginning,
  );

  await editor.pressKey(
    key: LogicalKeyboardKey.arrowDown,
    isControlPressed: Platform.isWindows || Platform.isLinux,
    isMetaPressed: Platform.isMacOS,
  );

  expect(
    editor.selection,
    Selection.single(path: [1], startOffset: text.length),
  );

  await editor.dispose();
}

Future<void> _testPressArrowKeyInNotCollapsedSelection(
  WidgetTester tester,
  bool isBackward,
) async {
  const text = 'Welcome to Appflowy 😁';
  final editor = tester.editor..addParagraphs(2, initialText: text);
  await editor.startTesting();

  final start = Position(path: [0], offset: 5);
  final end = Position(path: [1], offset: 10);
  final selection = Selection(
    start: isBackward ? start : end,
    end: isBackward ? end : start,
  );
  await editor.updateSelection(selection);
  await editor.pressKey(key: LogicalKeyboardKey.arrowLeft);
  expect(editor.selection?.start, start);

  await editor.updateSelection(selection);
  await editor.pressKey(key: LogicalKeyboardKey.arrowRight);
  expect(editor.selection?.end, end);

  await editor.dispose();
}

Future<void> _pressShortcutToNavigateAroundWord(
  TestableEditor editor, {
  bool toRight = true,
}) async {
  await editor.pressKey(
    key: toRight ? LogicalKeyboardKey.arrowRight : LogicalKeyboardKey.arrowLeft,
    isAltPressed: Platform.isMacOS,
    isControlPressed: Platform.isWindows || Platform.isLinux,
  );
}
