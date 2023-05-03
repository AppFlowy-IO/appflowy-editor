import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// Backspace key event.
///
/// - support
///   - desktop
///   - web
///
final CommandShortcutEvent backspaceCommand = CommandShortcutEvent(
  key: 'backspace',
  command: 'backspace',
  handler: _backspaceCommandHandler,
);

final CommandShortcutEvent deleteLeftWordCommand = CommandShortcutEvent(
  key: 'delete the left word',
  command: 'ctrl+backspace',
  macOSCommand: 'alt+backspace',
  handler: _deleteLeftWordCommandHandler,
);

final CommandShortcutEvent deleteLeftSentenceCommand = CommandShortcutEvent(
  key: 'delete the left word',
  command: 'ctrl+alt+backspace',
  macOSCommand: 'cmd+backspace',
  handler: _deleteLeftSentenceCommandHandler,
);

CommandShortcutEventHandler _deleteLeftWordCommandHandler = (editorState) {
  final selection = editorState.selection;
  if (selection == null || !selection.isSingle) {
    return KeyEventResult.ignored;
  }

  final node = editorState.getNodeAtPath(selection.end.path);
  final delta = node?.delta;
  if (node == null || delta == null) {
    return KeyEventResult.ignored;
  }

  // we store the position where the current word starts.
  var startOfWord = selection.end.moveHorizontal(
    editorState,
    selectionRange: SelectionRange.word,
  );

  if (startOfWord == null) {
    return KeyEventResult.ignored;
  }

  //check if the selected word is whitespace
  final selectedWord = delta.toPlainText().substring(
        startOfWord.offset,
        selection.end.offset,
      );

  // if it is whitespace then we have to update the selection to include
  //  the left word from the whitespace.
  if (selectedWord.trim().isEmpty) {
    //make a new selection from the left of the whitespace.
    final newSelection = Selection.single(
      path: startOfWord.path,
      startOffset: startOfWord.offset,
    );

    //we need to check if this position is not null
    final newStartOfWord = newSelection.end.moveHorizontal(
      editorState,
      selectionRange: SelectionRange.word,
    );

    //this handles the edge case where the textNode only consists single space.
    if (newStartOfWord != null) {
      startOfWord = newStartOfWord;
    }
  }

  final transaction = editorState.transaction;
  transaction.deleteText(
    node,
    startOfWord.offset,
    selection.end.offset - startOfWord.offset,
  );

  editorState.apply(transaction);

  return KeyEventResult.handled;
};

CommandShortcutEventHandler _deleteLeftSentenceCommandHandler = (editorState) {
  final selection = editorState.selection;
  if (selection == null || !selection.isCollapsed) {
    return KeyEventResult.ignored;
  }

  final node = editorState.getNodeAtPath(selection.end.path);
  final delta = node?.delta;
  if (node == null || delta == null) {
    return KeyEventResult.ignored;
  }

  final transaction = editorState.transaction;
  transaction.deleteText(
    node,
    0,
    selection.endIndex,
  );
  editorState.apply(transaction);
  return KeyEventResult.handled;
};

CommandShortcutEventHandler _backspaceCommandHandler = (editorState) {
  if (PlatformExtension.isMobile) {
    assert(false, 'backspaceCommand is not supported on mobile platform.');
    return KeyEventResult.ignored;
  }
  final selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }
  if (selection.isCollapsed) {
    return _backspaceInCollapsedSelection(editorState);
  } else {
    return _backspaceInNotCollapsedSelection(editorState);
  }
};

/// Handle backspace key event when selection is collapsed.
CommandShortcutEventHandler _backspaceInCollapsedSelection = (editorState) {
  final selection = editorState.selection;
  if (selection == null || !selection.isCollapsed) {
    return KeyEventResult.ignored;
  }

  final position = selection.start;
  final node = editorState.getNodeAtPath(position.path);
  if (node == null || node.delta == null) {
    return KeyEventResult.ignored;
  }

  // Why do we use prevRunPosition instead of the position start offset?
  // Because some character's length > 1, for example, emoji.
  final index = node.delta!.prevRunePosition(position.offset);
  final transaction = editorState.transaction;
  if (index < 0) {
    // move this node to it's parent in below case.
    // the node's next is null
    // and the node's children is empty
    if (node.next == null &&
        node.children.isEmpty &&
        node.parent?.parent != null &&
        node.parent?.delta != null) {
      final path = node.parent!.path.next;
      transaction
        ..deleteNode(node)
        ..insertNode(path, node)
        ..afterSelection = Selection.collapsed(
          Position(
            path: path,
            offset: 0,
          ),
        );
    } else {
      // merge with the previous node contains delta.
      final previousNodeWithDelta =
          node.previousNodeWhere((element) => element.delta != null);
      if (previousNodeWithDelta != null) {
        assert(previousNodeWithDelta.delta != null);
        transaction
          ..mergeText(previousNodeWithDelta, node)
          ..insertNodes(
            // insert children to previous node
            previousNodeWithDelta.path.next,
            node.children.toList(),
          )
          ..deleteNode(node)
          ..afterSelection = Selection.collapsed(
            Position(
              path: previousNodeWithDelta.path,
              offset: previousNodeWithDelta.delta!.length,
            ),
          );
      } else {
        // do nothing if there is no previous node contains delta.
        return KeyEventResult.ignored;
      }
    }
  } else {
    // Although the selection may be collapsed,
    //  its length may not always be equal to 1 because some characters have a length greater than 1.
    transaction.deleteText(
      node,
      index,
      position.offset - index,
    );
  }

  editorState.apply(transaction);
  return KeyEventResult.handled;
};

/// Handle backspace key event when selection is not collapsed.
CommandShortcutEventHandler _backspaceInNotCollapsedSelection = (editorState) {
  final selection = editorState.selection;
  if (selection == null || selection.isCollapsed) {
    return KeyEventResult.ignored;
  }
  editorState.deleteSelection(selection);
  return KeyEventResult.handled;
};
