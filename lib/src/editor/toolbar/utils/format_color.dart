import 'package:appflowy_editor/appflowy_editor.dart';

void formatHighlightColor(EditorState editorState, String color) {
  editorState.formatDelta(
    editorState.selection,
    {AppFlowyRichTextKeys.highlightColor: color},
    false,
  );
}

void formatFontColor(EditorState editorState, String color) {
  editorState.formatDelta(
    editorState.selection,
    {AppFlowyRichTextKeys.textColor: color},
    false,
  );
}
