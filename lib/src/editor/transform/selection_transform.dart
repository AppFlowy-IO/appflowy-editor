import 'package:appflowy_editor/appflowy_editor.dart';

extension SelectionTransform on EditorState {
  Future<bool> deleteSelection(Selection selection) async {
    if (selection.isCollapsed) {
      return false;
    }

    selection = selection.normalized;
    final transaction = this.transaction;
    final nodes = getNodesInSelection(selection);

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
    } else {
      assert(nodes.first.path < nodes.last.path);
      for (var i = 0; i < nodes.length; i++) {
        final node = nodes[i];
        if (node.delta != null) {
          if (i == 0) {
            if (nodes.last.delta != null) {
              transaction.mergeText(
                node,
                nodes.last,
                leftOffset: selection.startIndex,
                rightOffset: selection.endIndex,
              );
            } else {
              transaction.deleteText(
                node,
                selection.startIndex,
                selection.length,
              );
            }
          } else {
            transaction.deleteNode(node);
          }
        } else {
          transaction.deleteNode(node);
        }
      }
    }

    transaction.afterSelection = selection.collapse(atStart: true);

    await apply(transaction);
    return true;
  }
}
