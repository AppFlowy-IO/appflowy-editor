import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/util/util.dart';
import 'package:flutter/material.dart';

/// Backspace key event.
///
/// - support
///   - desktop
///   - web
///
CommandShortcutEvent backspaceCommand = CommandShortcutEvent(
  key: 'backspace',
  command: 'backspace',
  handler: _backspaceCommandHandler,
);

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
  }
  return KeyEventResult.ignored;
};

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
