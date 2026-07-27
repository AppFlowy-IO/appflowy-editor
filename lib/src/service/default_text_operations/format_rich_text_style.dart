import 'package:appflowy_editor/appflowy_editor.dart';

Future<bool> insertHeadingAfterSelection(
  EditorState editorState,
  int level,
) async {
  return insertNodeAfterSelection(
    editorState,
    headingNode(level: level),
  );
}

Future<bool> insertQuoteAfterSelection(EditorState editorState) async {
  return insertNodeAfterSelection(
    editorState,
    quoteNode(),
  );
}

Future<bool> insertCheckboxAfterSelection(EditorState editorState) async {
  return insertNodeAfterSelection(
    editorState,
    todoListNode(checked: false),
  );
}

Future<bool> insertBulletedListAfterSelection(EditorState editorState) async {
  return insertNodeAfterSelection(
    editorState,
    bulletedListNode(),
  );
}

Future<bool> insertNumberedListAfterSelection(EditorState editorState) async {
  return insertNodeAfterSelection(
    editorState,
    numberedListNode(),
  );
}

Future<bool> insertNodeAfterSelection(
  EditorState editorState,
  Node node,
) async {
  final selection = editorState.selection;
  if (selection == null || !selection.isCollapsed) {
    return false;
  }

  final currentNode = editorState.getNodeAtPath(selection.end.path);
  if (currentNode == null) {
    return false;
  }
  node.updateAttributes({
    blockComponentTextDirection:
        currentNode.attributes[blockComponentTextDirection],
  });

  final transaction = editorState.transaction;
  final delta = currentNode.delta;
  if (delta != null && delta.isEmpty) {
    transaction
      ..insertNode(selection.end.path, node)
      ..deleteNode(currentNode)
      ..afterSelection =
          Selection.collapsed(Position(path: selection.end.path));
  } else {
    final next = selection.end.path.next;
    transaction
      ..insertNode(next, node)
      ..afterSelection = Selection.collapsed(Position(path: next));
  }

  await editorState.apply(transaction);
  return true;
}
