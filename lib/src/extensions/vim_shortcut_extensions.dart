import 'package:appflowy_editor/appflowy_editor.dart';

Position? moveVerticalMultiple(
  EditorState editorState,
  Position startPosition, {
  required bool upwards,
  required int count,
}) {
  Position? current = startPosition;
  for (int i = 0; i < count; i++) {
    current = current?.moveVertical(editorState, upwards: upwards);
    if (current == null) break;
  }
  return current;
}

Position? moveHorizontalMultiple(
  EditorState editorState,
  Position startPosition, {
  required bool forward,
  required int count,
}) {
  Position? current = startPosition;
  for (int i = 0; i < count; i++) {
    current = current?.moveHorizontal(editorState, forward: forward);
    if (current == null) break;
  }
  return current;
}
