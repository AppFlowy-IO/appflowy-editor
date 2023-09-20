import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// Backspace key event.
///
/// - support
///   - desktop
///   - web
///   - mobile
///
final CommandShortcutEvent backspaceCommand = CommandShortcutEvent(
  key: 'backspace',
  command: 'backspace',
  handler: _backspaceCommandHandler,
);

CommandShortcutEventHandler _backspaceCommandHandler = (editorState) {
  final selection = editorState.selection;
  final selectionType = editorState.selectionType;

  if (selection == null) {
    return KeyEventResult.ignored;
  }

  if (selectionType == SelectionType.block) {
    return _backspaceInBlockSelection(editorState);
  } else if (selection.isCollapsed) {
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
      Node? tableParent =
          node.findParent((element) => element.type == TableBlockKeys.type);
      Node? prevTableParent;
      final prev = node.previousNodeWhere((element) {
        prevTableParent = element
            .findParent((element) => element.type == TableBlockKeys.type);
        // break if only one is in a table or they're in different tables
        return tableParent != prevTableParent ||
            // merge with the previous node contains delta.
            element.delta != null;
      });
      // table nodes should be deleted using the table menu
      // in-table paragraphs should only be deleted inside the table
      if (prev != null && tableParent == prevTableParent) {
        assert(prev.delta != null);
        transaction
          ..mergeText(prev, node)
          ..insertNodes(
            // insert children to previous node
            prev.path.next,
            node.children.toList(),
          )
          ..deleteNode(node)
          ..afterSelection = Selection.collapsed(
            Position(
              path: prev.path,
              offset: prev.delta!.length,
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

CommandShortcutEventHandler _backspaceInBlockSelection = (editorState) {
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
