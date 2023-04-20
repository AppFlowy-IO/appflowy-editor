import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/block_component/base_component/service/extensions/extensions.dart';

extension DeleteSelection on EditorState {
  Future<void> deleteSelection(Selection? selection) async {
    final transaction = this.transaction;
    if (selection == null || selection.isCollapsed) {
      return;
    }

    final normalized = selection.normalized;
    final nodes = this.selection.getNodesInSelection(normalized);

    transaction.afterSelection = normalized.collapse(atStart: true);

    // single line
    if (nodes.length == 1) {
      final node = nodes.first;
      if (node.delta != null) {
        transaction.deleteText2(node, normalized.startIndex, normalized.length);
      } else {
        transaction.deleteNode(node);
      }
      return apply(transaction);
    } else {
      throw UnimplementedError();
    }
  }
}
