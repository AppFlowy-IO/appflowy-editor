import 'package:appflowy_editor/appflowy_editor.dart';

extension InsertNewLine on EditorState {
  Future<void> insertNewLine2(Selection? selection) async {
    if (selection == null || !selection.isCollapsed) {
      return;
    }

    final transaction = this.transaction;
    final path = selection.start.path.next;

    transaction.insertNode(
      path,
      Node(
        type: 'paragraph',
        attributes: {
          'delta': Delta().toJson(),
        },
      ),
    );
    transaction.afterSelection = Selection.collapsed(
      Position(
        path: path,
        offset: 0,
      ),
    );

    return apply(transaction);
  }
}
