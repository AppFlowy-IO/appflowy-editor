import 'package:appflowy_editor/appflowy_editor.dart';

void formatHighlightColor(EditorState editorState, String? color) {
  editorState.formatDelta(
    editorState.selection,
    {FlowyRichTextKeys.highlightColor: color},
  );
}

void formatFontColor(EditorState editorState, String? color) {
  editorState.formatDelta(
    editorState.selection,
    {FlowyRichTextKeys.textColor: color},
  );
}
