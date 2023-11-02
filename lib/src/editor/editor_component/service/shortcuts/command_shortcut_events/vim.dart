import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'dart:math';

final List<CommandShortcutEvent> vimKeyModes = [
  ///Insert Methods
  insertOnNewLineCommand,
  insertInlineCommand,
  insertNextInlineCommand,

  ///Vim Movements
  jumpUpCommand,
  jumpDownCommand,
  jumpLeftCommand,
  jumpRightCommand,

  ///Vim Jump to line
  //BUG: Won't work properly keyboard shortcut fails
  // vimJumpToLineCommand,

  ///Page Movements
  //BUG: Conflicts with ctrl+b key
  // vimPageUpCommand,
  vimHalfPageDownCommand,
  vimPageDownCommand,
  //BUG: Conflicts with ctrl+u key
  // vimHalfPageUpCommand,

  ///Undo Commands
  //BUG: These commands won't work not sure why but
  //The undoManager doesnt work in normal mode
  // vimUndoCommand,
  // vimRedoCommand,

  ///Navigate line Commands
  vimMoveCursorToStartCommand,
  vimMoveCursorToEndCommand,
  jumpWordBackwardCommand,
  jumpWordForwardCommand,
  //BUG: Selection doesnt show up to user
  // vimSelectLineCommand,

  ///Text operations
  //BUG: Deleting at the end of text will cause the widget tree to panic
  //NOTE: Probably try using the 'delete' button instead
  // vimDeleteUnderCursorCommand,
];

/// Insert trigger keys
final CommandShortcutEvent insertOnNewLineCommand = CommandShortcutEvent(
  key: 'insert new line below previous selection',
  command: 'o',
  handler: _insertOnNewLineCommandHandler,
);

CommandShortcutEventHandler _insertOnNewLineCommandHandler = (editorState) {
  final afKeyboard = editorState.service.keyboardServiceKey;

  if (afKeyboard.currentState != null &&
      afKeyboard.currentState is AppFlowyKeyboardService) {
    if (editorState.selection == null || editorState.prevSelection != null) {
      //NOTE: Call editable first before changing mode
      editorState.editable = true;
      editorState.mode = VimModes.insertMode;
      editorState.selection = editorState.selection;
      editorState.insertNewLine();
      editorState.selectionService.updateSelection(editorState.selection);
      editorState.prevSelection = null;
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }
  return KeyEventResult.ignored;
};

final CommandShortcutEvent insertInlineCommand = CommandShortcutEvent(
  key: 'enter insert mode from previous selection',
  command: 'i',
  handler: _insertInlineCommandHandler,
);

CommandShortcutEventHandler _insertInlineCommandHandler = (editorState) {
  final afKeyboard = editorState.service.keyboardServiceKey;
  if (afKeyboard.currentState != null &&
      afKeyboard.currentState is AppFlowyKeyboardService) {
    if (editorState.selection == null || editorState.prevSelection != null) {
      //NOTE: Call editable first before changing mode
      editorState.editable = true;
      editorState.mode = VimModes.insertMode;
      editorState.selection = editorState.selection;
      editorState.selectionService.updateSelection(editorState.selection);
      editorState.prevSelection = null;
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }
  return KeyEventResult.ignored;
};

final CommandShortcutEvent insertNextInlineCommand = CommandShortcutEvent(
  key: 'enter insert mode on next character',
  command: 'a',
  handler: _insertNextInlineCommandHandler,
);

CommandShortcutEventHandler _insertNextInlineCommandHandler = (editorState) {
  final afKeyboard = editorState.service.keyboardServiceKey;
  if (afKeyboard.currentState != null &&
      afKeyboard.currentState is AppFlowyKeyboardService) {
    if (editorState.selection == null || editorState.prevSelection != null) {
      //NOTE: Call editable first before changing mode
      editorState.editable = true;
      editorState.mode = VimModes.insertMode;
      editorState.selection = editorState.selection;
      editorState.moveCursor(SelectionMoveDirection.backward);
      editorState.selectionService.updateSelection(editorState.selection);
      editorState.prevSelection = null;
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }
  return KeyEventResult.ignored;
};

/// Motion Keys
final CommandShortcutEvent jumpDownCommand = CommandShortcutEvent(
  key: 'move the cursor downward in normal mode',
  command: 'j',
  handler: _jumpDownCommandHandler,
);

CommandShortcutEventHandler _jumpDownCommandHandler = (editorState) {
  if (!editorState.vimMode) {
    return KeyEventResult.ignored;
  }
  final afKeyboard = editorState.service.keyboardServiceKey;
  if (afKeyboard.currentState != null &&
      afKeyboard.currentState is AppFlowyKeyboardService) {
    if (editorState.selection != null &&
        editorState.mode == VimModes.normalMode) {
      final selection = editorState.selection;
      final downPosition =
          selection?.end.moveVertical(editorState, upwards: false);
      editorState.updateSelectionWithReason(
          downPosition == null ? null : Selection.collapsed(downPosition),
          reason: SelectionUpdateReason.uiEvent);
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }
  return KeyEventResult.ignored;
};

final CommandShortcutEvent jumpUpCommand = CommandShortcutEvent(
  key: 'move the cursor upward in normal mode',
  command: 'k',
  handler: _jumpUpCommandHandler,
);

CommandShortcutEventHandler _jumpUpCommandHandler = (editorState) {
  if (!editorState.vimMode) {
    return KeyEventResult.ignored;
  }
  final afKeyboard = editorState.service.keyboardServiceKey;
  if (afKeyboard.currentState != null &&
      afKeyboard.currentState is AppFlowyKeyboardService) {
    // editorState.scrollService!.goBallistic(4);
    if (editorState.selection != null &&
        editorState.mode == VimModes.normalMode) {
      final selection = editorState.selection;
      final upPosition =
          selection?.end.moveVertical(editorState, upwards: true);
      editorState.updateSelectionWithReason(
        upPosition == null ? null : Selection.collapsed(upPosition),
        reason: SelectionUpdateReason.uiEvent,
      );
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }
  return KeyEventResult.ignored;
};

final CommandShortcutEvent jumpLeftCommand = CommandShortcutEvent(
  key: 'move the cursor to the left in normal mode',
  command: 'h',
  handler: _jumpLeftCommandHandler,
);

CommandShortcutEventHandler _jumpLeftCommandHandler = (editorState) {
  if (!editorState.vimMode) {
    return KeyEventResult.ignored;
  }
  final afKeyboard = editorState.service.keyboardServiceKey;
  if (afKeyboard.currentState != null &&
      afKeyboard.currentState is AppFlowyKeyboardService) {
    if (editorState.selection != null &&
        editorState.mode == VimModes.normalMode) {
      final selection = editorState.selection;
      final leftPosition =
          selection?.end.moveHorizontal(editorState, forward: true);
      editorState.updateSelectionWithReason(
        leftPosition == null ? null : Selection.collapsed(leftPosition),
        reason: SelectionUpdateReason.uiEvent,
      );
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }
  return KeyEventResult.ignored;
};

final CommandShortcutEvent jumpRightCommand = CommandShortcutEvent(
  key: 'move the cursor to the right in normal mode',
  command: 'l',
  handler: _jumpRightCommandHandler,
);

CommandShortcutEventHandler _jumpRightCommandHandler = (editorState) {
  if (!editorState.vimMode) {
    return KeyEventResult.ignored;
  }
  final afKeyboard = editorState.service.keyboardServiceKey;
  if (afKeyboard.currentState != null &&
      afKeyboard.currentState is AppFlowyKeyboardService) {
    if (editorState.selection != null &&
        editorState.mode == VimModes.normalMode) {
      final selection = editorState.selection;
      final rightPosition =
          selection?.end.moveHorizontal(editorState, forward: false);
      editorState.updateSelectionWithReason(
        rightPosition == null ? null : Selection.collapsed(rightPosition),
        reason: SelectionUpdateReason.uiEvent,
      );
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }
  return KeyEventResult.ignored;
};

//BUG: Selection does not show up in normal mode
final CommandShortcutEvent vimSelectLineCommand = CommandShortcutEvent(
  key: 'enter insert mode from previous selection',
  command: 'shift+v',
  handler: _vimSelectLineCommandHandler,
);

CommandShortcutEventHandler _vimSelectLineCommandHandler = (editorState) {
  final afKeyboard = editorState.service.keyboardServiceKey;
  if (afKeyboard.currentState != null &&
      afKeyboard.currentState is AppFlowyKeyboardService) {
    if (editorState.selection == null || editorState.prevSelection != null) {
      //NOTE: Call editable first before changing mode
      editorState.selection = editorState.selection;
      final selection = editorState.selection;
      editorState.selectionService.updateSelection(selection);
      editorState.prevSelection = null;

      final nodes = editorState.getNodesInSelection(selection!);
      if (nodes.isEmpty) {
        return KeyEventResult.ignored;
      }
      var end = selection.end;
      final position = isRTL(editorState)
          ? nodes.last.selectable?.end()
          : nodes.last.selectable?.start();
      if (position != null) {
        end = position;
      }
      editorState.updateSelectionWithReason(
        selection.copyWith(end: end),
        reason: SelectionUpdateReason.uiEvent,
      );
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }
  return KeyEventResult.ignored;
};
final CommandShortcutEvent vimUndoCommand = CommandShortcutEvent(
  key: 'vim undo in normal mode',
  command: 'u',
  handler: _vimUndoCommandHandler,
);

CommandShortcutEventHandler _vimUndoCommandHandler = (editorState) {
  if (!editorState.vimMode) {
    return KeyEventResult.ignored;
  }
  final afKeyboard = editorState.service.keyboardServiceKey;
  if (afKeyboard.currentState != null &&
      afKeyboard.currentState is AppFlowyKeyboardService) {
    if (editorState.selection != null &&
        editorState.mode == VimModes.normalMode) {
      //BUG: undo doesnt work in Normal mode
      //NOTE: Could be something to do with selection
      editorState.undoManager.undo();
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }
  return KeyEventResult.ignored;
};

final CommandShortcutEvent vimRedoCommand = CommandShortcutEvent(
  key: 'vim redo in normal mode',
  command: 'ctrl+r',
  handler: _vimRedoCommandHandler,
);

CommandShortcutEventHandler _vimRedoCommandHandler = (editorState) {
  if (!editorState.vimMode) {
    return KeyEventResult.ignored;
  }
  final afKeyboard = editorState.service.keyboardServiceKey;
  if (afKeyboard.currentState != null &&
      afKeyboard.currentState is AppFlowyKeyboardService) {
    if (editorState.selection != null &&
        editorState.mode == VimModes.normalMode) {
      //BUG: This also doesnt work in Normal mode
      editorState.undoManager.redo();
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }
  return KeyEventResult.ignored;
};

final CommandShortcutEvent vimPageDownCommand = CommandShortcutEvent(
  key: 'scroll one page down in normal mode',
  command: 'ctrl+f',
  handler: _vimPageDownCommandHandler,
);

CommandShortcutEventHandler _vimPageDownCommandHandler = (editorState) {
  if (!editorState.vimMode) {
    return KeyEventResult.ignored;
  }
  final afKeyboard = editorState.service.keyboardServiceKey;
  if (afKeyboard.currentState != null &&
      afKeyboard.currentState is AppFlowyKeyboardService) {
    if (editorState.selection != null &&
        editorState.mode == VimModes.normalMode) {
      final scrollService = editorState.service.scrollService;
      if (scrollService == null) {
        return KeyEventResult.ignored;
      }

      final scrollHeight = scrollService.onePageHeight;
      final dy = max(0, scrollService.dy);
      if (scrollHeight == null) {
        return KeyEventResult.ignored;
      }
      scrollService.scrollTo(
        dy + scrollHeight,
        duration: const Duration(milliseconds: 150),
      );
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }
  return KeyEventResult.ignored;
};
//NOTE: Move the cursor as well when moving the page
final CommandShortcutEvent vimHalfPageDownCommand = CommandShortcutEvent(
  key: 'scroll half page down in normal mode',
  command: 'ctrl+d',
  handler: _vimHalfPageDownCommandHandler,
);

CommandShortcutEventHandler _vimHalfPageDownCommandHandler = (editorState) {
  if (!editorState.vimMode) {
    return KeyEventResult.ignored;
  }
  final afKeyboard = editorState.service.keyboardServiceKey;
  if (afKeyboard.currentState != null &&
      afKeyboard.currentState is AppFlowyKeyboardService) {
    if (editorState.selection != null &&
        editorState.mode == VimModes.normalMode) {
      final scrollService = editorState.service.scrollService;
      if (scrollService == null) {
        return KeyEventResult.ignored;
      }

      final scrollHeight = scrollService.onePageHeight;
      final dy = max(0, scrollService.dy);
      if (scrollHeight == null) {
        return KeyEventResult.ignored;
      }
      scrollService.scrollTo(
        (dy + scrollHeight) / 2,
        duration: const Duration(milliseconds: 150),
      );
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }
  return KeyEventResult.ignored;
};
//NOTE: Bug page up event not triggered could be conflicting with other keys
final CommandShortcutEvent vimPageUpCommand = CommandShortcutEvent(
  key: 'scroll one page up in normal mode',
  command: 'ctrl+b',
  handler: _vimPageUpCommandHandler,
);

CommandShortcutEventHandler _vimPageUpCommandHandler = (editorState) {
  if (PlatformExtension.isMobile) {
    assert(false, 'pageUpCommand is not supported on mobile platform.');
    return KeyEventResult.ignored;
  }

  if (!editorState.vimMode) {
    return KeyEventResult.ignored;
  }
  final afKeyboard = editorState.service.keyboardServiceKey;
  if (afKeyboard.currentState != null &&
      afKeyboard.currentState is AppFlowyKeyboardService) {
    if (editorState.selection != null &&
        editorState.mode == VimModes.normalMode) {
      final scrollService = editorState.service.scrollService;
      if (scrollService == null) {
        return KeyEventResult.ignored;
      }

      final scrollHeight = scrollService.onePageHeight;
      final dy = scrollService.dy;
      if (dy <= 0 || scrollHeight == null) {
        return KeyEventResult.ignored;
      }
      scrollService.scrollTo(
        dy - scrollHeight,
        duration: const Duration(milliseconds: 150),
      );
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }
  return KeyEventResult.ignored;
};

final CommandShortcutEvent vimHalfPageUpCommand = CommandShortcutEvent(
  key: 'scroll one page up in normal mode',
  command: 'ctrl+u',
  handler: _vimHalfPageUpCommandHandler,
);

CommandShortcutEventHandler _vimHalfPageUpCommandHandler = (editorState) {
  if (PlatformExtension.isMobile) {
    assert(false, 'pageUpCommand is not supported on mobile platform.');
    return KeyEventResult.ignored;
  }

  if (!editorState.vimMode) {
    return KeyEventResult.ignored;
  }
  final afKeyboard = editorState.service.keyboardServiceKey;
  if (afKeyboard.currentState != null &&
      afKeyboard.currentState is AppFlowyKeyboardService) {
    if (editorState.mode == VimModes.normalMode) {
      final scrollService = editorState.service.scrollService;
      if (scrollService == null) {
        return KeyEventResult.ignored;
      }

      final scrollHeight = scrollService.onePageHeight;
      final dy = scrollService.dy;
      if (dy <= 0 || scrollHeight == null) {
        return KeyEventResult.ignored;
      }
      scrollService.scrollTo(
        dy - scrollHeight,
        duration: const Duration(milliseconds: 150),
      );
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }
  return KeyEventResult.ignored;
};

///Navigate on the current line
final CommandShortcutEvent vimMoveCursorToStartCommand = CommandShortcutEvent(
  key: 'vim move cursor to start of line in normal mode',
  command: 'Digit 0',
  handler: _vimMoveCursorToStartHandler,
);

CommandShortcutEventHandler _vimMoveCursorToStartHandler = (editorState) {
  if (!editorState.vimMode) {
    return KeyEventResult.ignored;
  }
  final afKeyboard = editorState.service.keyboardServiceKey;
  if (afKeyboard.currentState != null &&
      afKeyboard.currentState is AppFlowyKeyboardService) {
    if (editorState.selection != null &&
        editorState.mode == VimModes.normalMode) {
      if (isRTL(editorState)) {
        editorState.moveCursorBackward(SelectionMoveRange.line);
      } else {
        editorState.moveCursorForward(SelectionMoveRange.line);
      }
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }
  return KeyEventResult.ignored;
};

final CommandShortcutEvent vimMoveCursorToEndCommand = CommandShortcutEvent(
  key: 'vim move cursor to end of line in normal mode',
  //NOTE: Used Digit 4, dollar sign would throw error
  command: 'shift+Digit 4',
  handler: _vimMoveCursorToEndHandler,
);

CommandShortcutEventHandler _vimMoveCursorToEndHandler = (editorState) {
  if (!editorState.vimMode) {
    return KeyEventResult.ignored;
  }
  final afKeyboard = editorState.service.keyboardServiceKey;
  if (afKeyboard.currentState != null &&
      afKeyboard.currentState is AppFlowyKeyboardService) {
    if (editorState.selection != null &&
        editorState.mode == VimModes.normalMode) {
      if (isRTL(editorState)) {
        editorState.moveCursorForward(SelectionMoveRange.line);
      } else {
        editorState.moveCursorBackward(SelectionMoveRange.line);
      }
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }
  return KeyEventResult.ignored;
};

final CommandShortcutEvent jumpWordBackwardCommand = CommandShortcutEvent(
  key: 'move the cursor backward to the next wordl in normal mode',
  command: 'b',
  handler: _jumpWordBackwardCommandHandler,
);

CommandShortcutEventHandler _jumpWordBackwardCommandHandler = (editorState) {
  if (!editorState.vimMode) {
    return KeyEventResult.ignored;
  }
  final afKeyboard = editorState.service.keyboardServiceKey;
  if (afKeyboard.currentState != null &&
      afKeyboard.currentState is AppFlowyKeyboardService) {
    if (editorState.selection != null &&
        editorState.mode == VimModes.normalMode) {
      final selection = editorState.selection;

      final node = editorState.getNodeAtPath(selection!.end.path);
      final delta = node?.delta;

      if (node == null || delta == null) {
        return KeyEventResult.ignored;
      }

      if (isRTL(editorState)) {
        final endOfWord = selection.end.moveHorizontal(
          editorState,
          forward: false,
          selectionRange: SelectionRange.word,
        );
        final selectedWord = delta.toPlainText().substring(
              selection.end.offset,
              endOfWord?.offset,
            );
        // check if the selected word is whitespace
        if (selectedWord.trim().isEmpty) {
          editorState.moveCursorBackward(SelectionMoveRange.word);
        }
        editorState.moveCursorBackward(SelectionMoveRange.word);
      } else {
        final startOfWord = selection.end.moveHorizontal(
          editorState,
          selectionRange: SelectionRange.word,
        );
        if (startOfWord == null) {
          return KeyEventResult.handled;
        }
        final selectedWord = delta.toPlainText().substring(
              startOfWord.offset,
              selection.end.offset,
            );
        // check if the selected word is whitespace
        if (selectedWord.trim().isEmpty) {
          editorState.moveCursorForward(SelectionMoveRange.word);
        }
        editorState.moveCursorForward(SelectionMoveRange.word);
      }

      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }
  return KeyEventResult.ignored;
};

final CommandShortcutEvent jumpWordForwardCommand = CommandShortcutEvent(
  key: 'move the cursor backward to the next wordl in normal mode',
  command: 'w',
  handler: _jumpWordForwardCommandHandler,
);

CommandShortcutEventHandler _jumpWordForwardCommandHandler = (editorState) {
  if (!editorState.vimMode) {
    return KeyEventResult.ignored;
  }
  final afKeyboard = editorState.service.keyboardServiceKey;
  if (afKeyboard.currentState != null &&
      afKeyboard.currentState is AppFlowyKeyboardService) {
    if (editorState.selection != null &&
        editorState.mode == VimModes.normalMode) {
      final selection = editorState.selection;
      final node = editorState.getNodeAtPath(selection!.end.path);
      final delta = node?.delta;

      if (node == null || delta == null) {
        return KeyEventResult.ignored;
      }

      if (isRTL(editorState)) {
        final startOfWord = selection.end.moveHorizontal(
          editorState,
          selectionRange: SelectionRange.word,
        );
        if (startOfWord == null) {
          return KeyEventResult.ignored;
        }
        final selectedWord = delta.toPlainText().substring(
              startOfWord.offset,
              selection.end.offset,
            );
        // check if the selected word is whitespace
        if (selectedWord.trim().isEmpty) {
          editorState.moveCursorForward(SelectionMoveRange.word);
        }
        editorState.moveCursorForward(SelectionMoveRange.word);
      } else {
        final endOfWord = selection.end.moveHorizontal(
          editorState,
          forward: false,
          selectionRange: SelectionRange.word,
        );
        if (endOfWord == null) {
          return KeyEventResult.handled;
        }
        final selectedLine = delta.toPlainText();
        final selectedWord = selectedLine.substring(
          selection.end.offset,
          endOfWord.offset,
        );
        // check if the selected word is whitespace
        if (selectedWord.trim().isEmpty) {
          editorState.moveCursorBackward(SelectionMoveRange.word);
        }
        editorState.moveCursorBackward(SelectionMoveRange.word);
      }
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }
  return KeyEventResult.ignored;
};

final numList = List.generate(10, (i) => i);
final movements = [
  jumpDownCommand,
  jumpUpCommand,
];
/*
 * The idea for this is to at least use
 *  a list for the numbers & key movements.
 * Then from there jump accordingly, although 
 * might need to intercept that raw key event
 * Manually of course
 Basically -> 5j means jump five lines down
 */
final CommandShortcutEvent vimJumpToLineCommand = CommandShortcutEvent(
  key: 'vim move cursor to start of line in normal mode',
  //TODO: Find a way to await & chain shortcuts or key presses
  //Well modifying the keyevent directly won't end well. Since the focus node only reads one keyevent at a time
  // command: 'Digit 5',
  command: 'Digit 5' 'j',
  handler: _vimJumpToLineHandler,
);

CommandShortcutEventHandler _vimJumpToLineHandler = (editorState) {
  if (!editorState.vimMode) {
    return KeyEventResult.ignored;
  }
  final afKeyboard = editorState.service.keyboardServiceKey;
  if (afKeyboard.currentState != null &&
      afKeyboard.currentState is AppFlowyKeyboardService) {
    if (editorState.selection != null &&
        editorState.mode == VimModes.normalMode) {
      final selection = editorState.selection;
      //NOTE: Hard wired for now
      //Besides this is just for scrolling doesnt move the cursor
      editorState.scrollService?.jumpTo(5);
      SelectionMoveRange downRange = SelectionMoveRange.line;
      //This will be tricky need to modify 'select_commands.dart'
      //BUG: It throws an error on a blank line
      editorState.moveCursor(SelectionMoveDirection.backward, downRange);
      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }
  return KeyEventResult.ignored;
};

//BUG: Transaction to delete word won't apply
final CommandShortcutEvent vimDeleteUnderCursorCommand = CommandShortcutEvent(
  key: 'vim delete character under cursor in normal mode',
  command: 'd',
  handler: _vimDeleteUnderCursorHandler,
);

CommandShortcutEventHandler _vimDeleteUnderCursorHandler = (editorState) {
  if (!editorState.vimMode) {
    return KeyEventResult.ignored;
  }
  final afKeyboard = editorState.service.keyboardServiceKey;
  if (afKeyboard.currentState != null &&
      afKeyboard.currentState is AppFlowyKeyboardService) {
    if (editorState.selection != null &&
        editorState.mode == VimModes.normalMode) {
      final selection = editorState.selection;
      final selectionType = editorState.selectionType;
      print(selectionType);
      if (selectionType == SelectionType.block) {
        print('block section!');
        return _deleteInBlockSelection(editorState);
      } else if (selection!.isCollapsed) {
        print('collapsed section!');
        return _deleteInCollapsedSelection(editorState);
      } else {
        print('not in collapsed section!');
        return _deleteInNotCollapsedSelection(editorState);
      }
    }
  }
  return KeyEventResult.ignored;
};

///Delete Handlers

/// Handle delete key event when selection is collapsed.
CommandShortcutEventHandler _deleteInCollapsedSelection = (editorState) {
  final selection = editorState.selection;
  if (selection == null || !selection.isCollapsed) {
    return KeyEventResult.ignored;
  }

  final position = selection.start;
  final node = editorState.getNodeAtPath(position.path);
  final delta = node?.delta;
  if (node == null || delta == null) {
    return KeyEventResult.ignored;
  }

  final transaction = editorState.transaction;

  if (position.offset == delta.length) {
    Node? tableParent =
        node.findParent((element) => element.type == TableBlockKeys.type);
    Node? nextTableParent;
    final next = node.findDownward((element) {
      nextTableParent =
          element.findParent((element) => element.type == TableBlockKeys.type);
      // break if only one is in a table or they're in different tables
      return tableParent != nextTableParent ||
          // merge the next node with delta
          element.delta != null;
    });
    // table nodes should be deleted using the table menu
    // in-table paragraphs should only be deleted inside the table
    if (next != null && tableParent == nextTableParent) {
      if (next.children.isNotEmpty) {
        final path = node.path + [node.children.length];
        transaction.insertNodes(path, next.children);
      }
      transaction
        ..deleteNode(next)
        ..mergeText(
          node,
          next,
        );
      editorState.apply(transaction);
      return KeyEventResult.handled;
    }
  } else {
    //NOTE: This is for normal text blocks but not being triggered
    final nextIndex = delta.nextRunePosition(position.offset);
    if (nextIndex <= delta.length) {
      transaction.deleteText(
        node,
        position.offset,
        nextIndex - position.offset,
      );
      editorState.apply(transaction);
      return KeyEventResult.handled;
    }
  }

  return KeyEventResult.ignored;
};

/// Handle delete key event when selection is not collapsed.
CommandShortcutEventHandler _deleteInNotCollapsedSelection = (editorState) {
  final selection = editorState.selection;
  if (selection == null || selection.isCollapsed) {
    return KeyEventResult.ignored;
  }
  editorState.deleteSelection(selection);
  return KeyEventResult.handled;
};

CommandShortcutEventHandler _deleteInBlockSelection = (editorState) {
  final selection = editorState.selection;
  if (selection == null || editorState.selectionType != SelectionType.block) {
    return KeyEventResult.ignored;
  }
  final transaction = editorState.transaction;
  transaction.deleteNodesAtPath(selection.start.path);
  editorState
      .apply(transaction)
      .then((value) => editorState.selectionType = null);

  return KeyEventResult.handled;
};
