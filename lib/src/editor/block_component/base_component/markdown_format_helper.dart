import 'package:appflowy_editor/appflowy_editor.dart';

/// Formats the current node to specified markdown style.
///
/// For example,
///   bulleted list: '- '
///   numbered list: '1. '
///   quote: '" '
///   ...
Future<bool> formatMarkdownSymbol(
  EditorState editorState,
  bool Function(Node node) shouldFormat,
  bool Function(
    String text,
    Selection selection,
  )
      predicate,
  Node Function(
    String text,
    Node node,
    Delta delta,
  )
      nodeBuilder,
) async {
  final selection = editorState.selection;
  if (selection == null || !selection.isCollapsed) {
    return false;
  }

  final position = selection.end;
  final node = editorState.getNodeAtPath(position.path);

  if (node == null || !shouldFormat(node)) {
    return false;
  }

  // Get the text from the start of the document until the selection.
  final delta = node.delta;
  if (delta == null) {
    return false;
  }
  final text = delta.toPlainText().substring(0, selection.end.offset);

  // If the text doesn't match the predicate, then we don't want to
  // format it.
  if (!predicate(text, selection)) {
    return false;
  }

  final afterSelection = Selection.collapsed(
    Position(
      path: node.path,
      offset: 0,
    ),
  );

  final formattedNode = nodeBuilder(text, node, delta);

  // Create a transaction that replaces the current node with the
  // formatted node.
  final transaction = editorState.transaction
    ..insertNode(
      node.path,
      formattedNode,
    )
    ..deleteNode(node)
    ..afterSelection = afterSelection;

  await editorState.apply(transaction);
  return true;
}
