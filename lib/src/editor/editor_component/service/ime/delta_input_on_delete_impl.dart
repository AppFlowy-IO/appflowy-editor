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

  // use backspace command instead.
  backspaceCommand.execute(editorState);
}
