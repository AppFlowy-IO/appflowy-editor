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
    final node = editorState.getNodeAtPath(selection.end.path);
    final delta = node?.delta;
    if (node == null || delta == null) {
      return;
    }

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
