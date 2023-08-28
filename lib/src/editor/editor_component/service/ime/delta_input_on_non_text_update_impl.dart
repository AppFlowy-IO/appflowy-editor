import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';

Future<void> onNonTextUpdate(
  TextEditingDeltaNonTextUpdate nonTextUpdate,
  EditorState editorState,
) async {
  // update the selection on Windows
  //
  // when typing characters with CJK IME on Windows, a non-text update is sent
  // with the selection range.

  if (PlatformExtension.isWindows) {
    final selection = editorState.selection;
    if (selection != null &&
        nonTextUpdate.composing == TextRange.empty &&
        nonTextUpdate.selection.isCollapsed) {
      editorState.selection = Selection.collapsed(
        Position(
          path: selection.start.path,
          offset: nonTextUpdate.selection.start,
        ),
      );
    }
  }
}
