import 'dart:math';

import 'package:appflowy_editor/src/core/document/attributes.dart';
import 'package:appflowy_editor/src/core/document/document.dart';
import 'package:appflowy_editor/src/core/document/node.dart';
import 'package:appflowy_editor/src/core/document/path.dart';
import 'package:appflowy_editor/src/core/document/text_delta.dart';
import 'package:appflowy_editor/src/core/location/position.dart';
import 'package:appflowy_editor/src/core/location/selection.dart';
import 'package:appflowy_editor/src/core/transform/operation.dart';

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
    add(
      InsertOperation(
        path,
        deepCopy ? nodes.map((e) => e.copyWith()) : nodes,
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

  /// Update the [TextNode]s with the given [Delta].
  void updateText(TextNode textNode, Delta delta) {
    final inverted = delta.invert(textNode.delta);
    add(UpdateTextOperation(textNode.path, delta, inverted));
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
  void add(Operation op, {bool transform = true}) {
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
        op = transformOperation(_operations[i], op);
      }
    }
    if (op is UpdateTextOperation && op.delta.isEmpty) {
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

  // the below code is deprecated.
  void splitText(TextNode textNode, int offset) {
    final delta = textNode.delta;
    final second = delta.slice(offset, delta.length);
    final path = textNode.path.next;
    deleteText(textNode, offset, delta.length);
    insertNode(
      path,
      TextNode(
        attributes: textNode.attributes,
        delta: second,
      ),
    );
    afterSelection = Selection.collapsed(
      Position(
        path: path,
        offset: 0,
      ),
    );
  }

  /// Inserts the text content at a specified index.
  ///
  /// Optionally, you may specify formatting attributes that are applied to the inserted string.
  /// By default, the formatting attributes before the insert position will be reused.
  // void insertText(
  //   TextNode textNode,
  //   int index,
  //   String text, {
  //   Attributes? attributes,
  // }) {
  //   var newAttributes = attributes;
  //   if (index != 0 && attributes == null) {
  //     newAttributes =
  //         textNode.delta.slice(max(index - 1, 0), index).first.attributes;
  //     if (newAttributes != null) {
  //       newAttributes = {...newAttributes}; // make a copy
  //     }
  //   }
  //   updateText(
  //     textNode,
  //     Delta()
  //       ..retain(index)
  //       ..insert(text, attributes: newAttributes),
  //   );
  //   afterSelection = Selection.collapsed(
  //     Position(path: textNode.path, offset: index + text.length),
  //   );
  // }

  /// Assigns a formatting attributes to a range of text.
  // void formatText(
  //   TextNode textNode,
  //   int index,
  //   int length,
  //   Attributes attributes,
  // ) {
  //   afterSelection = beforeSelection;
  //   updateText(
  //     textNode,
  //     Delta()
  //       ..retain(index)
  //       ..retain(length, attributes: attributes),
  //   );
  // }

  // /// Deletes the text of specified length starting at index.
  // void deleteText(
  //   TextNode textNode,
  //   int index,
  //   int length,
  // ) {
  //   updateText(
  //     textNode,
  //     Delta()
  //       ..retain(index)
  //       ..delete(length),
  //   );
  //   afterSelection = Selection.collapsed(
  //     Position(path: textNode.path, offset: index),
  //   );
  // }

  /// Replaces the text of specified length starting at index.
  ///
  /// Optionally, you may specify formatting attributes that are applied to the inserted string.
  /// By default, the formatting attributes before the insert position will be reused.
  void replaceText(
    TextNode textNode,
    int index,
    int length,
    String text, {
    Attributes? attributes,
  }) {
    var newAttributes = attributes;
    if (index != 0 && attributes == null) {
      newAttributes =
          textNode.delta.slice(max(index - 1, 0), index).first.attributes;
      if (newAttributes == null) {
        final slicedDelta = textNode.delta.slice(index, index + length);
        if (slicedDelta.isNotEmpty) {
          newAttributes = slicedDelta.first.attributes;
        }
      }
    }
    updateText(
      textNode,
      Delta()
        ..retain(index)
        ..delete(length)
        ..insert(text, attributes: {...newAttributes ?? {}}),
    );
    afterSelection = Selection.collapsed(
      Position(
        path: textNode.path,
        offset: index + text.length,
      ),
    );
  }

  void replaceTexts(
    List<TextNode> textNodes,
    Selection selection,
    List<String> texts,
  ) {
    if (textNodes.isEmpty || texts.isEmpty) {
      return;
    }

    if (textNodes.length == texts.length) {
      final length = textNodes.length;

      if (length == 1) {
        replaceText(
          textNodes.first,
          selection.startIndex,
          selection.endIndex - selection.startIndex,
          texts.first,
        );
        return;
      }

      for (var i = 0; i < textNodes.length; i++) {
        final textNode = textNodes[i];
        if (i == 0) {
          replaceText(
            textNode,
            selection.startIndex,
            textNode.toPlainText().length,
            texts.first,
          );
        } else if (i == length - 1) {
          replaceText(
            textNode,
            0,
            selection.endIndex,
            texts.last,
          );
        } else {
          replaceText(
            textNode,
            0,
            textNode.toPlainText().length,
            texts[i],
          );
        }
      }
      return;
    }

    if (textNodes.length > texts.length) {
      final length = textNodes.length;
      for (var i = 0; i < textNodes.length; i++) {
        final textNode = textNodes[i];
        if (i == 0) {
          replaceText(
            textNode,
            selection.startIndex,
            textNode.toPlainText().length,
            texts.first,
          );
        } else if (i == length - 1 && texts.length >= 2) {
          replaceText(
            textNode,
            0,
            selection.endIndex,
            texts.last,
          );
        } else if (i < texts.length - 1) {
          replaceText(
            textNode,
            0,
            textNode.toPlainText().length,
            texts[i],
          );
        } else {
          deleteNode(textNode);
          if (i == textNodes.length - 1) {
            final delta = Delta()
              ..insert(texts[0])
              ..addAll(
                textNodes.last.delta.slice(selection.end.offset),
              );
            replaceText(
              textNode,
              selection.start.offset,
              texts[0].length,
              delta.toPlainText(),
            );
          }
        }
      }
      afterSelection = null;
      return;
    }

    if (textNodes.length < texts.length) {
      final length = texts.length;
      var path = textNodes.first.path;

      for (var i = 0; i < texts.length; i++) {
        final text = texts[i];
        if (i == 0) {
          replaceText(
            textNodes.first,
            selection.startIndex,
            textNodes.first.toPlainText().length,
            text,
          );
          path = path.next;
        } else if (i == length - 1 && textNodes.length >= 2) {
          replaceText(
            textNodes.last,
            0,
            selection.endIndex,
            text,
          );
          path = path.next;
        } else {
          if (i < textNodes.length - 1) {
            replaceText(
              textNodes[i],
              0,
              textNodes[i].toPlainText().length,
              text,
            );
            path = path.next;
          } else {
            if (i == texts.length - 1) {
              final delta = Delta()
                ..insert(text)
                ..addAll(
                  textNodes.last.delta.slice(selection.end.offset),
                );
              insertNode(
                path,
                TextNode(
                  delta: delta,
                ),
              );
            } else {
              insertNode(
                path,
                TextNode(
                  delta: Delta()..insert(text),
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
}

extension on Delta {
  Attributes? sliceAttributes(int index) {
    if (index <= 0) {
      return null;
    }

    return slice(index - 1, index).first.attributes;
  }
}
