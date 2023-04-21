import 'package:appflowy_editor/appflowy_editor.dart';

extension TextTransforms on EditorState {
  /// Inserts a new line at the given position.
  ///
  /// If the [Position] is not passed in, use the current selection.
  /// If there is no position, or if the selection is not collapsed, do nothing.
  ///
  /// Then it inserts a new paragraph node. After that, it sets the selection to be at the
  /// beginning of the new paragraph.
  Future<void> insertNewLine({
    Position? at,
  }) async {
    // If the position is not passed in, use the current selection.
    final position = at ?? selection.currentSelection.value?.start;

    // If there is no position, or if the selection is not collapsed, do nothing.
    if (position == null ||
        !(selection.currentSelection.value?.isCollapsed ?? false)) {
      return;
    }

    // Get the transaction and the path of the next node.
    final transaction = this.transaction;
    final path = position.path.next;

    // Insert a new paragraph node.
    transaction.insertNode(
      path,
      Node(
        type: 'paragraph',
        attributes: {
          'delta': Delta().toJson(),
        },
      ),
    );

    // Set the selection to be at the beginning of the new paragraph.
    transaction.afterSelection = Selection.collapsed(
      Position(
        path: path,
        offset: 0,
      ),
    );

    // Apply the transaction.
    await apply(transaction);
  }
}
