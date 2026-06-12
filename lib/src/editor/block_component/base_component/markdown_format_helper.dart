import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:collection/collection.dart';

const _nodeEquality = DeepCollectionEquality();

/// Formats the current node to specified markdown style.
///
/// For example,
///   bulleted list: '- '
///   numbered list: '1. '
///   quote: '" '
///   ...
///
/// The [nodeBuilder] can return a list of nodes, which will be inserted
///   into the document.
/// For example, when converting a bulleted list to a heading and the heading is
///  not allowed to contain children, then the [nodeBuilder] should return a list
///  of nodes, which contains the heading node and the children nodes.
Future<bool> formatMarkdownSymbol(
  EditorState editorState,
  bool Function(Node node) shouldFormat,
  bool Function(
    Node node,
    String text,
    Selection selection,
  ) predicate,
  List<Node> Function(
    String text,
    Node node,
    Delta delta,
  ) nodesBuilder,
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
  if (!predicate(node, text, selection)) {
    return false;
  }

  final afterSelection = Selection.collapsed(
    Position(
      path: node.path,
    ),
  );

  final formattedNodes = nodesBuilder(text, node, delta);

  final transaction = editorState.transaction;
  if (_canUpdateNodeTypeInPlace(node, formattedNodes)) {
    final formattedNode = formattedNodes.single;
    transaction.updateNodeType(
      node,
      formattedNode.type,
      formattedNode.attributes,
    );
  } else {
    // Create a transaction that replaces the current node with the
    // formatted node.
    transaction
      ..insertNodes(
        node.path,
        formattedNodes,
      )
      ..deleteNode(node);
  }
  transaction.afterSelection = afterSelection;

  await editorState.apply(transaction);
  return true;
}

bool _canUpdateNodeTypeInPlace(Node node, List<Node> formattedNodes) {
  if (formattedNodes.length != 1) {
    return false;
  }

  return _hasSameDescendantContent(node, formattedNodes.single);
}

bool _hasSameDescendantContent(Node before, Node after) {
  if (before.children.length != after.children.length) {
    return false;
  }

  for (var i = 0; i < before.children.length; i++) {
    final beforeChild = before.children.elementAt(i);
    final afterChild = after.children.elementAt(i);
    if (beforeChild.type != afterChild.type ||
        !_nodeEquality.equals(beforeChild.attributes, afterChild.attributes) ||
        !_hasSameDescendantContent(beforeChild, afterChild)) {
      return false;
    }
  }

  return true;
}
