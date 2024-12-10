import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> onDelete(
  TextEditingDeltaDeletion deletion,
  EditorState editorState,
) async {
  AppFlowyEditorLog.input.debug('onDelete: $deletion');

  final selection = editorState.selection;
  if (selection == null) {
    return;
  }

  // IME
  if (selection.isSingle) {
    final node = editorState.getNodeAtPath(selection.start.path);
    final delta = node?.delta;
    if (node != null &&
        delta != null &&
        (deletion.composing.isValid || !deletion.deletedRange.isCollapsed)) {
      final start = delta.prevRunePosition(deletion.deletedRange.end);
      final length = deletion.deletedRange.end - start;
      final transaction = editorState.transaction;
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
