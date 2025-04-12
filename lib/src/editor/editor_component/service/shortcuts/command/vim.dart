import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:appflowy_editor/src/editor/util/platform_extension.dart';
import 'dart:math';

final List<CommandShortcutEvent> vimKeyModes = [
  ///Insert Methods

  ///Vim Movements
  /*
  jumpUpCommand,
  jumpDownCommand,
  jumpLeftCommand,
  jumpRightCommand,
*/

  ///Vim Jump to line
  //BUG: Won't work properly keyboard shortcut fails
  // vimJumpToLineCommand,

  ///Page Movements
  //NOTE: Conflicts with ctrl+b key
  vimPageUpCommand,
  vimHalfPageDownCommand,
  vimPageDownCommand,
  //BUG: Not working for some reason
  //vimHalfPageUpCommand,

  ///Undo Commands
  //BUG: These commands won't work not sure why but
  //The undoManager doesnt work in normal mode
  /*
  There is an issue with transactions.
  When the editor is in Normal mode, transactions are closed. What ever happens
  then
  well wont work. Problem is undo & redo needs that transaction window open.
  Unless something is implemented to ignore all other keys unless they match
  a VIM key?
  */
  // vimUndoCommand,
  // vimRedoCommand,

  ///Navigate line Commands
  // vimMoveCursorToStartCommand,
  //vimMoveCursorToEndCommand,
  //BUG: Selection doesnt show up to user
  // vimSelectLineCommand,

  ///Text operations
  //BUG: Deleting at the end of text will cause the widget tree to panic
  //NOTE: Probably try using the 'delete' button instead
  // vimDeleteUnderCursorCommand,
];

//BUG: Selection does not show up in normal mode
final CommandShortcutEvent vimSelectLineCommand = CommandShortcutEvent(
  key: 'enter insert mode from previous selection',
  command: 'shift+v',
  handler: _vimSelectLineCommandHandler,
  getDescription: () => AppFlowyEditorL10n.current.cmdLineSelect,
);
/*
What we probably need is to follow the `select all command`
Except that we want to get the cursor position or line.
When we get line/position then select the whole line.
*/
CommandShortcutEventHandler _vimSelectLineCommandHandler = (editorState) {
  final afKeyboard = editorState.service.keyboardServiceKey;
  if (afKeyboard.currentState != null &&
      afKeyboard.currentState is AppFlowyKeyboardService) {
    if (editorState.selection == null || editorState.prevSelection != null) {
      //BUG: Throwing issue on PropertyValueNotifier
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

final CommandShortcutEvent vimPageDownCommand = CommandShortcutEvent(
  key: 'scroll one page down in normal mode',
  command: 'ctrl+f',
  handler: _vimPageDownCommandHandler,
  getDescription: () => AppFlowyEditorL10n.current.cmdVimJumpPageDown,
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
  getDescription: () => AppFlowyEditorL10n.current.cmdVimJumpHalfPageDown,
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

final CommandShortcutEvent vimPageUpCommand = CommandShortcutEvent(
  key: 'scroll one page up in normal mode',
  command: 'ctrl+b',
  handler: _vimPageUpCommandHandler,
  getDescription: () => AppFlowyEditorL10n.current.cmdVimJumpPageUp,
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
  getDescription: () => AppFlowyEditorL10n.current.cmdVimJumpPageUp,
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
