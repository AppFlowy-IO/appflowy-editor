import 'dart:math';

import 'package:appflowy_editor/appflowy_editor.dart';

extension InsertText on Transaction {
  // TODO: optimize this function.
  void insertText2(
    Node node,
    int index,
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
      if (newAttributes != null) {
        newAttributes = {...newAttributes}; // make a copy
      }
    }

    final now = delta.compose(
      Delta()
        ..retain(index)
        ..insert(text, attributes: newAttributes),
    );

    updateNode(node, {
      'delta': now.toJson(),
    });

    afterSelection = Selection.collapsed(
      Position(path: node.path, offset: index + text.length),
    );
  }
}
