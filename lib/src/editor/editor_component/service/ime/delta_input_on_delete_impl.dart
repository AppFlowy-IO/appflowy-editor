import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/extensions/extensions.dart';
import 'package:flutter/services.dart';

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
  if (selection.isSingle) {
    final node = editorState.selection.currentSelectedNodes.first;
    assert(node.delta != null);

    final transaction = editorState.transaction
      ..deleteText2(
        node,
        deletion.deletedRange.start,
        deletion.textDeleted.length,
      );
    return editorState.apply(transaction);
  } else {
    throw UnimplementedError();
  }
}
