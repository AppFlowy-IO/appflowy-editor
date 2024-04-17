import 'package:appflowy_editor/appflowy_editor.dart';

import 'package:flutter/material.dart';

Future<void> onPerformAction(
  TextInputAction action,
  EditorState editorState,
) async {
  print('call back check perform action');
  Log.input.debug('onPerformAction: $action');
}
