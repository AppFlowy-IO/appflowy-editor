import 'dart:math';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';

Future<bool> executeCharacterShortcutEvent(
  EditorState editorState,
  String character,
) async {
  final shortcutEvents = editorState.characterShortcutEvents;
  for (final shortcutEvent in shortcutEvents) {
    if (shortcutEvent.character == character &&
        await shortcutEvent.handler(editorState)) {
      return true;
    }
  }
  return false;
}

Future<void> onInsert(
  TextEditingDeltaInsertion insertion,
  EditorState editorState,
) async {
  Log.input.debug('onInsert: $insertion');

  // character events
  final character = insertion.textInserted;
  if (character.length == 1) {
    final execution = await executeCharacterShortcutEvent(
      editorState,
      character,
    );
    if (execution) {
      return;
    }
  }

  final selection = editorState.selection.currentSelection.value;
  if (selection == null) {
    return;
  }

  // IME
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
}
