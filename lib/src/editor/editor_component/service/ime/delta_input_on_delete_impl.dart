import 'package:appflowy_editor/appflowy_editor.dart';
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

  // single line
  if (selection.isSingle) {
    final node = editorState.selectionService.currentSelectedNodes.first;
    assert(node.delta != null);

    final transaction = editorState.transaction
      ..deleteText(
        node,
        deletion.deletedRange.start,
        deletion.textDeleted.length,
      );
    return editorState.apply(transaction);
  } else {
    throw UnimplementedError();
  }
}
