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
    Node Function(Node node)? nodeBuilder,
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

    final slicedDelta = delta == null ? Delta() : delta.slice(position.offset);
    final Map<String, dynamic> attributes = {
      'delta': slicedDelta.toJson(),
    };

    // Copy the text direction from the current node.
    final textDirection =
        node.attributes[blockComponentTextDirection] as String?;
    if (textDirection != null) {
      attributes[blockComponentTextDirection] = textDirection;
    }

    final insertedNode = paragraphNode(
      attributes: attributes,
      children: children,
    );
    nodeBuilder ??= (node) => node.copyWith();

    // Insert a new paragraph node.
    transaction.insertNode(
      next,
      nodeBuilder(insertedNode),
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
  Future<void> formatDelta(
    Selection? selection,
    Attributes attributes, [
    bool withUpdateSelection = true,
  ]) async {
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

    return apply(
      transaction,
      withUpdateSelection: withUpdateSelection,
    );
  }

  /// Toggles the given attribute on or off for the selected text.
  ///
  /// If the [Selection] is not passed in, use the current selection.
  Future<void> toggleAttribute(
    String key, {
    Selection? selection,
  }) async {
    selection ??= this.selection;
    if (selection == null) {
      return;
    }
    final nodes = getNodesInSelection(selection);
    final isHighlight = nodes.allSatisfyInSelection(selection, (delta) {
      return delta.everyAttributes(
        (attributes) => attributes[key] == true,
      );
    });
    formatDelta(
      selection,
      {
        key: !isHighlight,
      },
    );
  }

  /// format the node at the given selection.
  ///
  /// If the [Selection] is not passed in, use the current selection.
  Future<void> formatNode(
    Selection? selection,
    Node Function(
      Node node,
    ) nodeBuilder,
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

  /// Insert text at the given index of the given [Node] or the [Path].
  ///
  /// [Path] and [Node] are mutually exclusive.
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

  /// Get the attributes in the given selection.
  ///
  /// If the [Selection] is not passed in, use the current selection.
  ///
  T? getDeltaAttributeValueInSelection<T>(
    String key, [
    Selection? selection,
  ]) {
    selection ??= this.selection;
    selection = selection?.normalized;
    if (selection == null || !selection.isSingle) {
      return null;
    }
    final node = getNodeAtPath(selection.end.path);
    final delta = node?.delta;
    if (delta == null) {
      return null;
    }
    final ops = delta.whereType<TextInsert>();
    final startOffset = selection.start.offset;
    final endOffset = selection.end.offset;
    var start = 0;
    for (final op in ops) {
      if (start >= endOffset) {
        break;
      }
      final length = op.length;
      if (start < endOffset && start + length > startOffset) {
        final attributes = op.attributes;
        if (attributes != null &&
            attributes.containsKey(key) &&
            attributes[key] is T) {
          return attributes[key] as T;
        }
      }
      start += length;
    }
    return null;
  }
}
