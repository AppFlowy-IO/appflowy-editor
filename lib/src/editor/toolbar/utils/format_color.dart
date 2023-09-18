import 'package:appflowy_editor/appflowy_editor.dart';

void formatHighlightColor(
  EditorState editorState,
  Selection? selection,
  String? color, {
  bool withUpdateSelection = false,
}) {
  editorState.formatDelta(
    selection,
    {AppFlowyRichTextKeys.highlightColor: color},
    withUpdateSelection,
  );
}

void formatFontColor(
  EditorState editorState,
  Selection? selection,
  String? color, {
  bool withUpdateSelection = false,
}) {
  editorState.formatDelta(
    selection,
    {AppFlowyRichTextKeys.textColor: color},
    withUpdateSelection,
  );
}
