import 'package:appflowy_editor/appflowy_editor.dart';

void formatHighlightColor(
  EditorState editorState,
  Selection? selection,
  String color,
) {
  editorState.formatDelta(
    selection,
    {AppFlowyRichTextKeys.highlightColor: color},
    false,
  );
}

void formatFontColor(
  EditorState editorState,
  Selection? selection,
  String color,
) {
  editorState.formatDelta(
    selection,
    {AppFlowyRichTextKeys.textColor: color},
    false,
  );
}
