import 'package:appflowy_editor/appflowy_editor.dart';

Future<bool> insertNewLineInType(
  EditorState editorState,
  String type, {
  Attributes attributes = const {},
}) async {
  final selection = editorState.selection;
  if (selection == null || !selection.isCollapsed) {
    return false;
  }

  final node = editorState.getNodeAtPath(selection.end.path);
  if (node?.type != type) {
    return false;
  }

  await editorState.insertNewLine(
    nodeBuilder: (delta) => Node(
      type: type,
      attributes: {
        'delta': delta.toJson(),
        ...attributes,
      },
    ),
  );
  return true;
}
