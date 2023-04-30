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
    Position? position,
  }) async {
    // If the position is not passed in, use the current selection.
    position ??= selection?.start;

    // If there is no position, or if the selection is not collapsed, do nothing.
    if (position == null || !(selection?.isCollapsed ?? false)) {
      return;
    }

    final node = getNodeAtPath(position.path);

    if (node == null) {
      return;
    }

    // Get the transaction and the path of the next node.
    final transaction = this.transaction;
    final next = position.path.next;
    final children = node.children;
    final delta = node.delta;

    if (delta != null) {
      // Delete the text after the cursor in the current node.
      transaction.deleteText(
        node,
        position.offset,
        delta.length - position.offset,
      );
    }

    // Delete the current node's children if it is not empty.
    if (children.isNotEmpty) {
      transaction.deleteNodes(children);
    }

    // Insert a new paragraph node.
    transaction.insertNode(
      next,
      node.copyWith(
        type: 'paragraph',
        attributes: {
          'delta':
              (delta == null ? Delta() : delta.slice(position.offset)).toJson(),
        }, // move the current node's children to the new paragraph node if it has any.
      ),
      deepCopy: true,
    );

    // Set the selection to be at the beginning of the new paragraph.
    transaction.afterSelection = Selection.collapsed(
      Position(
        path: next,
        offset: 0,
      ),
    );

    // Apply the transaction.
    return apply(transaction);
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
    position ??= selection?.start;

    // If there is no position, or if the selection is not collapsed, do nothing.
    if (position == null || !(selection?.isCollapsed ?? false)) {
      return;
    }

    final path = position.path;
    final node = getNodeAtPath(path);

    if (node == null) {
      return;
    }

    // Get the transaction and the path of the next node.
    final transaction = this.transaction;
    final delta = node.delta;
    if (delta == null) {
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
    return apply(transaction);
  }

  /// format the delta at the given selection.
  ///
  /// If the [Selection] is not passed in, use the current selection.
  Future<void> formatDelta(Selection? selection, Attributes attributes) async {
    selection ??= this.selection;
    selection = selection?.normalized;

    if (selection == null || selection.isCollapsed) {
      return;
    }

    final nodes = getNodesInSelection(selection);
    if (nodes.isEmpty) {
      return;
    }

    final transaction = this.transaction;

    for (final node in nodes) {
      final delta = node.delta;
      if (delta == null) {
        continue;
      }
      final startIndex = node == nodes.first ? selection.startIndex : 0;
      final endIndex = node == nodes.last ? selection.endIndex : delta.length;
      transaction
        ..formatText(
          node,
          startIndex,
          endIndex - startIndex,
          attributes,
        )
        ..afterSelection = transaction.beforeSelection;
    }

    return apply(transaction);
  }

  /// format the node at the given selection.
  ///
  /// If the [Selection] is not passed in, use the current selection.
  Future<void> formatNode(
    Selection? selection,
    Node Function(
      Node node,
    )
        nodeBuilder,
  ) async {
    selection ??= this.selection;
    selection = selection?.normalized;

    if (selection == null) {
      return;
    }

    final nodes = getNodesInSelection(selection);
    if (nodes.isEmpty) {
      return;
    }

    final transaction = this.transaction;

    for (final node in nodes) {
      transaction
        ..insertNode(
          node.path,
          nodeBuilder(node),
        )
        ..deleteNode(node)
        ..afterSelection = transaction.beforeSelection;
    }

    return apply(transaction);
  }

  /// Insert text at the given index of the given [TextNode] or the [Path].
  ///
  /// [Path] and [TextNode] are mutually exclusive.
  /// One of these two parameters must have a value.
  Future<void> insertText(
    int index,
    String text, {
    Path? path,
    Node? node,
  }) async {
    node ??= getNodeAtPath(path!);
    if (node == null) {
      assert(false, 'node is null');
      return;
    }
    return apply(
      transaction..insertText(node, index, text),
    );
  }

  Future<void> insertTextAtCurrentSelection(String text) async {
    final selection = this.selection;
    if (selection == null || !selection.isCollapsed) {
      return;
    }
    return insertText(
      selection.startIndex,
      text,
      path: selection.end.path,
    );
  }

  /// Get the text in the given selection.
  ///
  /// If the [Selection] is not passed in, use the current selection.
  ///
  List<String> getTextInSelection([
    Selection? selection,
  ]) {
    List<String> res = [];
    selection ??= this.selection;
    if (selection == null || selection.isCollapsed) {
      return res;
    }
    final nodes = getNodesInSelection(selection);
    for (final node in nodes) {
      final delta = node.delta;
      if (delta == null) {
        continue;
      }
      final startIndex = node == nodes.first ? selection.startIndex : 0;
      final endIndex = node == nodes.last ? selection.endIndex : delta.length;
      res.add(delta.slice(startIndex, endIndex).toPlainText());
    }
    return res;
  }
}
