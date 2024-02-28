import 'package:appflowy_editor/appflowy_editor.dart';

void formatHighlightColor(
  EditorState editorState,
  Selection? selection,
  String? color, {
  bool withUpdateSelection = false,
}) {
  editorState.formatDelta(
    selection,
    {AppFlowyRichTextKeys.backgroundColor: color},
    withUpdateSelection: withUpdateSelection,
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
    withUpdateSelection: withUpdateSelection,
  );
}
