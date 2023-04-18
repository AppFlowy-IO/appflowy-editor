import 'dart:math';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';

Future<void> onInsert(
  TextEditingDeltaInsertion insertion,
  EditorState editorState,
) async {
  Log.input.debug('onInsert: $insertion');

  final selection = editorState.selection.currentSelection.value;
  if (selection == null) {
    return;
  }

  // single line
  if (selection.isCollapsed) {
    final node = editorState.selection.currentSelectedNodes.first;
    assert(node.delta != null);

    final transaction = editorState.transaction
      ..insertText2(
        node,
        insertion.insertionOffset,
        insertion.textInserted,
      );
    return editorState.apply(transaction);
  } else {
    throw UnimplementedError();
  }
}

Future<void> onDelete(
  TextEditingDeltaDeletion deletion,
  EditorState editorState,
) async {
  Log.input.debug('onDelete: $deletion');

  final selection = editorState.selection.currentSelection.value;
  if (selection == null) {
    return;
  }

  // single line
  if (selection.isCollapsed) {
    final node = editorState.selection.currentSelectedNodes.first;
    assert(node.delta != null);

    final transaction = editorState.transaction
      ..deleteText2(
        node,
        deletion.deletedRange.start,
        deletion.textDeleted,
      );
    return editorState.apply(transaction);
  } else {
    throw UnimplementedError();
  }
}

Future<void> onReplace(TextEditingDeltaReplacement replacement) async {
  Log.input.debug('onReplace: $replacement');
}

Future<void> onNonTextUpdate(
  TextEditingDeltaNonTextUpdate nonTextUpdate,
) async {}

extension on Transaction {
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

  void deleteText2(
    Node node,
    int index,
    String text,
  ) {
    final delta = node.delta;
    if (delta == null) {
      return;
    }

    final now = delta.compose(
      Delta()
        ..retain(index)
        ..delete(text.length),
    );

    updateNode(node, {
      'delta': now.toJson(),
    });

    afterSelection = Selection.collapsed(
      Position(path: node.path, offset: index),
    );
  }
}
