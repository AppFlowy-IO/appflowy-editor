import 'package:appflowy_editor/appflowy_editor.dart';

extension SelectionTransform on EditorState {
  /// Deletes the selection.
  ///
  /// If the selection is collapsed, this function does nothing.
  ///
  /// If the node contains a delta, this function deletes the text in the selection,
  ///   else the node does not contain a delta, this function deletes the node.
  ///
  /// If both the first node and last node contain a delta,
  ///   this function merges the delta of the last node into the first node,
  ///   and deletes the nodes in between.
  ///
  /// If only the first node contains a delta,
  ///   this function deletes the text in the first node,
  ///   and deletes the nodes expect for the first node.
  ///
  /// For the other cases, this function just deletes all the nodes.
  Future<bool> deleteSelection(Selection selection) async {
    // Nothing to do if the selection is collapsed.
    if (selection.isCollapsed) {
      return false;
    }

    // Normalize the selection so that it is never reversed or extended.
    selection = selection.normalized;

    // Start a new transaction.
    final transaction = this.transaction;

    // Get the nodes that are fully or partially selected.
    final nodes = getNodesInSelection(selection);

    // If only one node is selected, then we can just delete the selected text
    // or node.
    if (nodes.length == 1) {
      final node = nodes.first;
      if (node.delta != null) {
        transaction.deleteText(
          node,
          selection.startIndex,
          selection.length,
        );
      } else {
        transaction.deleteNode(node);
      }
    }

    // Otherwise, multiple nodes are selected, so we have to do more work.
    else {
      // The nodes are guaranteed to be in order, so we can determine which
      // nodes are at the beginning, middle, and end of the selection.
      assert(nodes.first.path < nodes.last.path);
      for (var i = 0; i < nodes.length; i++) {
        final node = nodes[i];

        // The first node is at the beginning of the selection.
        if (i == 0) {
          // If the last node is also a text node, then we can merge the text
          // between the two nodes.
          if (nodes.last.delta != null) {
            transaction.mergeText(
              node,
              nodes.last,
              leftOffset: selection.startIndex,
              rightOffset: selection.endIndex,
            );
          }

          // Otherwise, we can just delete the selected text.
          else {
            transaction.deleteText(
              node,
              selection.startIndex,
              selection.length,
            );
          }
        }

        // All other nodes can be deleted.
        else {
          transaction.deleteNode(node);
        }
      }
    }

    // After the selection is deleted, we want to move the selection to the
    // beginning of the deleted selection.
    transaction.afterSelection = selection.collapse(atStart: true);

    // Apply the transaction.
    await apply(transaction);
    return true;
  }
}
