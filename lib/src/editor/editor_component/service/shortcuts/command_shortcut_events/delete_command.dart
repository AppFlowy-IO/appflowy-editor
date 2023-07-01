import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// Delete key event.
///
/// - support
///   - desktop
///   - web
///
final CommandShortcutEvent deleteCommand = CommandShortcutEvent(
  key: 'Delete Key',
  command: 'delete',
  handler: _deleteCommandHandler,
);

CommandShortcutEventHandler _deleteCommandHandler = (editorState) {
  final selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }
  if (selection.isCollapsed) {
    return _deleteInCollapsedSelection(editorState);
  } else {
    return _deleteInNotCollapsedSelection(editorState);
  }
};

/// Handle delete key event when selection is collapsed.
CommandShortcutEventHandler _deleteInCollapsedSelection = (editorState) {
  final selection = editorState.selection;
  if (selection == null || !selection.isCollapsed) {
    return KeyEventResult.ignored;
  }

  final position = selection.start;
  final node = editorState.getNodeAtPath(position.path);
  if (node == null || node.delta == null) {
    return KeyEventResult.ignored;
  }

  // Why do we use nextRunePosition instead of the position end offset?
  // Because some character's length > 1, for example, emoji.
  final index = node.delta!.nextRunePosition(position.offset);
  final transaction = editorState.transaction;
  if (index == node.delta!.length) {
    // merge the next node in the current node.
    final nextNode = node.next;
    if (nextNode == null) {
      return KeyEventResult.ignored;
    }
    //TODO(Lucas): add logic for merging a bulletList or numberedList item.
    if (nextNode.next == null && nextNode.children.isEmpty) {
      final path = node.path;
      transaction
        ..mergeText(node, nextNode)
        ..deleteNode(nextNode)
        ..afterSelection = Selection.collapsed(
          Position(
            path: path,
            offset: index,
          ),
        );
    } else {
      // merge with the previous node contains delta.
      final nextNodeWithDelta =
          node.lastNodeWhere((element) => element.delta != null);
      if (nextNodeWithDelta != null) {
        assert(nextNodeWithDelta.delta != null);
        transaction
          ..mergeText(nextNodeWithDelta, node)
          ..insertNodes(
            // insert children to previous node
            nextNodeWithDelta.path.next,
            node.children.toList(),
          )
          ..deleteNode(node)
          ..afterSelection = Selection.collapsed(
            Position(
              path: nextNodeWithDelta.path,
              offset: nextNodeWithDelta.delta!.length,
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
      position.offset,
      index - position.offset,
    );
  }

  editorState.apply(transaction);
  return KeyEventResult.handled;
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
