import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> onDelete(
  TextEditingDeltaDeletion deletion,
  EditorState editorState,
) async {
  Log.input.debug('onDelete: $deletion');

  final selection = editorState.selection;
  if (selection == null) {
    return;
  }

  // IME
  if (selection.isSingle) {
    if (deletion.composing.isValid || !deletion.deletedRange.isCollapsed) {
      final node = editorState.getNodesInSelection(selection).first;
      final transaction = editorState.transaction;
      final start = deletion.deletedRange.start;
      final length = deletion.deletedRange.end - start;
      transaction.deleteText(node, start, length);
      await editorState.apply(transaction);
      return;
    }
  }

  // use backspace command instead.
  if (KeyEventResult.ignored ==
      convertToParagraphCommand.execute(editorState)) {
    backspaceCommand.execute(editorState);
  }
}
