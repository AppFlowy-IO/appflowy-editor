import 'dart:math';

import 'package:appflowy_editor/appflowy_editor.dart';

/// A [Transaction] has a list of [Operation] objects that will be applied
/// to the editor.
///
/// There will be several ways to consume the transaction:
/// 1. Apply to the state to update the UI.
/// 2. Send to the backend to store and do operation transforming.
class Transaction {
  Transaction({
    required this.document,
  });

  final Document document;

  /// The operations to be applied.
  final List<Operation> _operations = [];
  List<Operation> get operations {
    if (markNeedsComposing) {
      // compose the delta operations
      compose();
      markNeedsComposing = false;
    }
    return _operations;
  }

  set operations(List<Operation> value) {
    _operations.clear();
    _operations.addAll(value);
  }

  /// The selection to be applied.
  Selection? afterSelection;

  /// The before selection is to be recovered if needed.
  Selection? beforeSelection;

  // mark needs to be composed
  bool markNeedsComposing = false;

  /// Inserts the [Node] at the given [Path].
  void insertNode(
    Path path,
    Node node, {
    bool deepCopy = true,
  }) {
    insertNodes(path, [node], deepCopy: deepCopy);
  }

  /// Inserts a sequence of [Node]s at the given [Path].
  void insertNodes(
    Path path,
    Iterable<Node> nodes, {
    bool deepCopy = true,
  }) {
    if (nodes.isEmpty) {
      return;
    }
    if (deepCopy) {
      // add `toList()` to prevent the redundant copy of the nodes when looping
      nodes = nodes.map((e) => e.copyWith()).toList();
    }
    add(
      InsertOperation(
        path,
        nodes,
      ),
    );
  }

  /// Updates the attributes of the [Node].
  ///
  /// The [attributes] will be merged into the existing attributes.
  void updateNode(Node node, Attributes attributes) {
    final inverted = invertAttributes(node.attributes, attributes);
    add(
      UpdateOperation(
        node.path,
        {...attributes},
        inverted,
      ),
    );
  }

  /// Deletes the [Node] in the document.
  void deleteNode(Node node) {
    deleteNodesAtPath(node.path);
    if (beforeSelection != null) {
      final nodePath = node.path;
      final selectionPath = beforeSelection!.start.path;
      if (!(nodePath.equals(selectionPath))) {
        afterSelection = beforeSelection;
      }
    }
  }

  /// Deletes the [Node]s in the document.
  void deleteNodes(Iterable<Node> nodes) {
    nodes.forEach(deleteNode);
  }

  /// Deletes the [Node]s at the given [Path].
  ///
  /// The [length] indicates the number of consecutive deletions,
  ///   including the node of the current path.
  void deleteNodesAtPath(Path path, [int length = 1]) {
    if (path.isEmpty) return;
    final nodes = <Node>[];
    final parent = path.parent;
    for (var i = 0; i < length; i++) {
      final node = document.nodeAtPath(parent + [path.last + i]);
      if (node == null) {
        break;
      }
      nodes.add(node);
    }
    add(DeleteOperation(path, nodes));
  }

  /// Moves a [Node] to the provided [Path]
  void moveNode(Path path, Node node) {
    deleteNode(node);
    insertNode(path, node, deepCopy: false);
  }

  /// Returns the JSON representation of the transaction.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (operations.isNotEmpty) {
      json['operations'] = operations.map((o) => o.toJson()).toList();
    }
    if (afterSelection != null) {
      json['after_selection'] = afterSelection!.toJson();
    }
    if (beforeSelection != null) {
      json['before_selection'] = beforeSelection!.toJson();
    }
    return json;
  }

  /// Adds an operation to the transaction.
  /// This method will merge operations if they are both TextEdits.
  ///
  /// Also, this method will transform the path of the operations
  /// to avoid conflicts.
  void add(Operation operation, {bool transform = true}) {
    Operation? op = operation;
    final Operation? last = _operations.isEmpty ? null : _operations.last;
    if (last != null) {
      if (op is UpdateTextOperation &&
          last is UpdateTextOperation &&
          op.path.equals(last.path)) {
        final newOp = UpdateTextOperation(
          op.path,
          last.delta.compose(op.delta),
          op.inverted.compose(last.inverted),
        );
        operations[_operations.length - 1] = newOp;
        return;
      }
    }
    if (transform) {
      for (var i = 0; i < _operations.length; i++) {
        if (op == null) {
          continue;
        }
        op = transformOperation(_operations[i], op);
      }
    }
    if (op is UpdateTextOperation && op.delta.isEmpty) {
      return;
    }
    if (op == null) {
      return;
    }
    _operations.add(op);
  }
}

extension TextTransaction on Transaction {
  /// We use this map to cache the delta waiting to be composed.
  ///
  /// This is for make calling the below function as chained.
  /// For example, transaction..deleteText(..)..insertText(..);
  static final Map<Node, List<Delta>> _composeMap = {};

  /// Inserts the [text] at the given [index].
  ///
  /// If the [attributes] is null, the attributes of the previous character will be used.
  /// If the [attributes] is not null, the attributes will be used.
  void insertText(
    Node node,
    int index,
    String text, {
    Attributes? attributes,
  }) {
    final delta = node.delta;
    if (delta == null) {
      assert(false, 'The node must have a delta.');
      return;
    }

    assert(
      index <= delta.length && index >= 0,
      'The index($index) is out of range or negative.',
    );

    final newAttributes = attributes ?? delta.sliceAttributes(index);

    final insert = Delta()
      ..retain(index)
      ..insert(text, attributes: newAttributes);

    addDeltaToComposeMap(node, insert);

    afterSelection = Selection.collapsed(
      Position(path: node.path, offset: index + text.length),
    );
  }

  void insertTextDelta(
    Node node,
    int index,
    Delta insertedDelta,
  ) {
    final delta = node.delta;
    if (delta == null) {
      assert(false, 'The node must have a delta.');
      return;
    }

    assert(
      index <= delta.length && index >= 0,
      'The index($index) is out of range or negative.',
    );

    final insert = Delta()
      ..retain(index)
      ..addAll(insertedDelta);

    addDeltaToComposeMap(node, insert);

    afterSelection = Selection.collapsed(
      Position(path: node.path, offset: index + insertedDelta.length),
    );
  }

  /// Deletes the [length] characters at the given [index].
  void deleteText(
    Node node,
    int index,
    int length,
  ) {
    final delta = node.delta;
    if (delta == null) {
      assert(false, 'The node must have a delta.');
      return;
    }

    assert(
      index + length <= delta.length && index >= 0 && length >= 0,
      'The index($index) or length($length) is out of range or negative.',
    );

    final delete = Delta()
      ..retain(index)
      ..delete(length);

    addDeltaToComposeMap(node, delete);

    afterSelection = Selection.collapsed(
      Position(path: node.path, offset: index),
    );
  }

  void mergeText(
    Node left,
    Node right, {
    int? leftOffset,
    int rightOffset = 0,
  }) {
    final leftDelta = left.delta;
    final rightDelta = right.delta;
    if (leftDelta == null || rightDelta == null) {
      return;
    }
    final leftLength = leftDelta.length;
    final rightLength = rightDelta.length;
    leftOffset ??= leftLength;

    final merge = Delta()
      ..retain(leftOffset)
      ..delete(leftLength - leftOffset)
      ..addAll(rightDelta.slice(rightOffset, rightLength));

    addDeltaToComposeMap(left, merge);

    afterSelection = Selection.collapsed(
      Position(
        path: left.path,
        offset: leftOffset,
      ),
    );
  }

  void formatText(
    Node node,
    int index,
    int length,
    Attributes attributes,
  ) {
    final delta = node.delta;
    if (delta == null) {
      return;
    }
    afterSelection = beforeSelection;
    final format = Delta()
      ..retain(index)
      ..retain(length, attributes: attributes);

    addDeltaToComposeMap(node, format);
  }

  /// replace the text at the given [index] with the [text].
  void replaceText(
    Node node,
    int index,
    int length,
    String text, {
    Attributes? attributes,
  }) {
    final delta = node.delta;
    if (delta == null) {
      return;
    }
    var newAttributes = attributes;
    if (index != 0 && attributes == null) {
      newAttributes = delta.slice(max(index - 1, 0), index).first.attributes;
      if (newAttributes == null) {
        final slicedDelta = delta.slice(index, index + length);
        if (slicedDelta.isNotEmpty) {
          newAttributes = slicedDelta.first.attributes;
        }
      }
    }

    final replace = Delta()
      ..retain(index)
      ..delete(length)
      ..insert(text, attributes: {...newAttributes ?? {}});
    addDeltaToComposeMap(node, replace);

    afterSelection = Selection.collapsed(
      Position(
        path: node.path,
        offset: index + text.length,
      ),
    );
  }

  // TODO: refactor this code
  void replaceTexts(
    List<Node> nodes,
    Selection selection,
    List<String> texts,
  ) {
    if (nodes.isEmpty || texts.isEmpty) {
      return;
    }

    if (nodes.length == texts.length) {
      final length = nodes.length;

      if (length == 1) {
        replaceText(
          nodes.first,
          selection.startIndex,
          selection.endIndex - selection.startIndex,
          texts.first,
        );
        return;
      }

      for (var i = 0; i < nodes.length; i++) {
        final node = nodes[i];
        final delta = node.delta;
        if (delta == null) {
          continue;
        }
        if (i == 0) {
          replaceText(
            node,
            selection.startIndex,
            delta.length - selection.startIndex,
            texts.first,
          );
        } else if (i == length - 1) {
          replaceText(
            node,
            0,
            selection.endIndex,
            texts.last,
          );
        } else {
          replaceText(
            node,
            0,
            delta.toPlainText().length,
            texts[i],
          );
        }
      }
      return;
    }

    if (nodes.length > texts.length) {
      final length = nodes.length;
      for (var i = 0; i < nodes.length; i++) {
        final node = nodes[i];
        final delta = node.delta;
        if (delta == null) {
          continue;
        }
        if (i == 0) {
          replaceText(
            node,
            selection.startIndex,
            delta.length - selection.startIndex,
            texts.first,
          );
        } else if (i == length - 1 && texts.length >= 2) {
          replaceText(
            node,
            0,
            selection.endIndex,
            texts.last,
          );
        } else if (i < texts.length - 1) {
          replaceText(
            node,
            0,
            delta.length,
            texts[i],
          );
        } else {
          deleteNode(node);
          if (i == nodes.length - 1) {
            final delta = nodes.last.delta;
            if (delta == null) {
              continue;
            }
            final newDelta = Delta()
              ..insert(texts[0])
              ..addAll(
                delta.slice(selection.end.offset),
              );
            replaceText(
              node,
              selection.start.offset,
              texts[0].length,
              newDelta.toPlainText(),
            );
          }
        }
      }
      afterSelection = null;
      return;
    }

    if (nodes.length < texts.length) {
      final length = texts.length;
      var path = nodes.first.path;

      for (var i = 0; i < texts.length; i++) {
        final text = texts[i];
        if (i == 0) {
          final node = nodes.first;
          final delta = node.delta;
          if (delta == null) {
            continue;
          }
          replaceText(
            nodes.first,
            selection.startIndex,
            delta.length - selection.startIndex,
            text,
          );
          path = path.next;
        } else if (i == length - 1 && nodes.length >= 2) {
          replaceText(
            nodes.last,
            0,
            selection.endIndex,
            text,
          );
          path = path.next;
        } else {
          if (i < nodes.length - 1) {
            final node = nodes[i];
            final delta = node.delta;
            if (delta == null) {
              continue;
            }
            replaceText(
              node,
              0,
              delta.length,
              text,
            );
            path = path.next;
          } else {
            if (i == texts.length - 1) {
              final delta = nodes.last.delta;
              if (delta == null) {
                continue;
              }
              final mewDelta = Delta()
                ..insert(text)
                ..addAll(
                  delta.slice(selection.end.offset),
                );
              insertNode(
                path,
                Node(
                  type: 'paragraph',
                  attributes: {'delta': mewDelta.toJson()},
                ),
              );
            } else {
              insertNode(
                path,
                Node(
                  type: 'paragraph',
                  attributes: {'delta': (Delta()..insert(text)).toJson()},
                ),
              );
            }
          }
        }
      }
      afterSelection = null;
      return;
    }
  }

  /// Compose the delta in the compose map.
  void compose() {
    if (_composeMap.isEmpty) {
      markNeedsComposing = false;
      return;
    }
    for (final entry in _composeMap.entries) {
      final node = entry.key;
      if (node.delta == null) {
        continue;
      }
      final deltaQueue = entry.value;
      final composed =
          deltaQueue.fold<Delta>(node.delta!, (p, e) => p.compose(e));
      assert(composed.every((element) => element is TextInsert));
      updateNode(node, {
        'delta': composed.toJson(),
      });
    }
    markNeedsComposing = false;
    _composeMap.clear();
  }

  void addDeltaToComposeMap(Node node, Delta delta) {
    markNeedsComposing = true;
    _composeMap.putIfAbsent(node, () => []).add(delta);
  }
}
