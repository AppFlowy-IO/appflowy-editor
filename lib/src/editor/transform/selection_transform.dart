import 'package:appflowy_editor/appflowy_editor.dart';

extension SelectionTransform on EditorState {
  Future<void> deleteSelection(Selection selection) async {
    if (selection.isCollapsed) {
      return;
    }

    final transaction = this.transaction;
    final normalized = selection.normalized;
    final nodes = this.selection.getNodesInSelection(normalized);

    transaction.afterSelection = normalized.collapse(atStart: true);

    if (nodes.length == 1) {
      final node = nodes.first;
      if (node.delta != null) {
        transaction.deleteText(
          node,
          normalized.startIndex,
          normalized.length,
        );
      } else {
        transaction.deleteNode(node);
      }
    } else {
      for (var i = 0; i < nodes.length; i++) {
        final node = nodes[i];
        if (node.delta != null) {
          if (i == 0) {
            transaction.deleteText(
              node,
              normalized.startIndex,
              node.delta!.length - normalized.startIndex,
            );
          } else if (i == nodes.length - 1) {
            transaction.deleteText(
              node,
              0,
              normalized.endIndex,
            );
          } else {
            transaction.deleteNode(node);
          }
        } else {
          transaction.deleteNode(node);
        }
      }
    }

    return apply(transaction);
  }
}
