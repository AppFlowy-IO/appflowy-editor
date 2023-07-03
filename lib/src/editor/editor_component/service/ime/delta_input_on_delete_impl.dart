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
      final start = deletion.deletedRange.start;
      final length = deletion.deletedRange.end - start;
      // final firstNodeContainsDelta = editorState.document.root.children
      //     .firstWhereOrNull((element) => element.delta != null);
      // if (firstNodeContainsDelta != null &&
      //     node.path.equals(firstNodeContainsDelta.path) && start == 0) {

      //     }
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
