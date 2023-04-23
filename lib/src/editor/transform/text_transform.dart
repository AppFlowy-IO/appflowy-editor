import 'package:appflowy_editor/appflowy_editor.dart';

extension TextTransforms on EditorState {
  /// Inserts a new line at the given position.
  ///
  /// If the [Position] is not passed in, use the current selection.
  /// If there is no position, or if the selection is not collapsed, do nothing.
  ///
  /// Then it inserts a new paragraph node. After that, it sets the selection to be at the
  /// beginning of the new paragraph.
  Future<void> insertNewLine(
    Position? position,
  ) async {
    // If the position is not passed in, use the current selection.
    position = position ?? selectionService.currentSelection.value?.start;

    // If there is no position, or if the selection is not collapsed, do nothing.
    if (position == null ||
        !(selectionService.currentSelection.value?.isCollapsed ?? false)) {
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

  /// Inserts text at the given position.
  /// If the [Position] is not passed in, use the current selection.
  /// If there is no position, or if the selection is not collapsed, do nothing.
  /// Then it inserts the text at the given position.

  Future<void> insertTextAtPosition(
    String text, {
    Position? position,
  }) async {
    // If the position is not passed in, use the current selection.
    position = position ?? selectionService.currentSelection.value?.start;

    // If there is no position, or if the selection is not collapsed, do nothing.
    if (position == null ||
        !(selectionService.currentSelection.value?.isCollapsed ?? false)) {
      return;
    }

    // Get the transaction and the path of the next node.
    final transaction = this.transaction;
    final path = position.path;
    final node = getNodeAtPath(path);
    final delta = node?.delta;

    if (node == null || delta == null) {
      return;
    }

    // Insert the text at the given position.
    transaction.insertText(node, position.offset, text);

    // Set the selection to be at the beginning of the new paragraph.
    transaction.afterSelection = Selection.collapsed(
      Position(
        path: path,
        offset: position.offset + text.length,
      ),
    );

    // Apply the transaction.
    await apply(transaction);
  }
}
