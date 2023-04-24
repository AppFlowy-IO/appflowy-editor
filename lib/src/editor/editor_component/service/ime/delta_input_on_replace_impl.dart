import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';

Future<void> onReplace(
  TextEditingDeltaReplacement replacement,
  EditorState editorState,
) async {
  Log.input.debug('onReplace: $replacement');
}
