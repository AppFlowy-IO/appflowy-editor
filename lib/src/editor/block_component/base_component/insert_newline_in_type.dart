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
    nodeBuilder: (node) => node.copyWith(
      type: type,
      attributes: {
        ...node.attributes,
        ...attributes,
      },
    ),
  );
  return true;
}
