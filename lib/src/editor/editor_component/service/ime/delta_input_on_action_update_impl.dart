import 'package:appflowy_editor/appflowy_editor.dart';

import 'package:flutter/material.dart';

Future<void> onPerformAction(
  TextInputAction action,
  EditorState editorState,
) async {
  Log.input.debug('onPerformAction: $action');
}
