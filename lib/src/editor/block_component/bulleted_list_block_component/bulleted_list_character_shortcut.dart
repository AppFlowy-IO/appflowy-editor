import 'package:appflowy_editor/appflowy_editor.dart';

/// Convert '* ' to bulleted list
///
/// - support
///   - desktop
///   - mobile
///   - web
///
CharacterShortcutEvent formatAsteriskToBulletedList = CharacterShortcutEvent(
  key: 'format asterisk to bulleted list',
  character: ' ',
  handler: (editorState) async =>
      await _formatSymbolToBulletedList(editorState, '*'),
);

/// Convert '- ' to bulleted list
///
/// - support
///   - desktop
///   - mobile
///   - web
///
CharacterShortcutEvent formatMinusToBulletedList = CharacterShortcutEvent(
  key: 'format minus to bulleted list',
  character: ' ',
  handler: (editorState) async =>
      await _formatSymbolToBulletedList(editorState, '-'),
);

// This function formats a symbol in the selection to a bulleted list.
// If the selection is not collapsed, it returns false.
// If the selection is collapsed and the text is not the symbol, it returns false.
// If the selection is collapsed and the text is the symbol, it will format the current node to a bulleted list.
Future<bool> _formatSymbolToBulletedList(
  EditorState editorState,
  String symbol,
) async {
  assert(symbol.length == 1);

  final selection = editorState.selection;
  if (selection == null || !selection.isCollapsed) {
    return false;
  }

  final nodes = editorState.getNodesInSelection(selection);
  if (nodes.length != 1 || nodes.first.type == 'bulleted_list') {
    return false;
  }

  final node = nodes.first;
  final delta = node.delta;
  if (delta == null) {
    return false;
  }
  final text = delta.toPlainText().substring(0, selection.end.offset);
  if (symbol != text) {
    return false;
  }

  final afterSelection = Selection.collapsed(
    Position(
      path: node.path,
      offset: 0,
    ),
  );
  final bulletedListNode = Node(
    type: 'bulleted_list',
    attributes: {
      'delta': delta.compose(Delta()..delete(symbol.length)).toJson(),
    },
  );
  final transaction = editorState.transaction
    ..insertNode(
      node.path,
      bulletedListNode,
    )
    ..deleteNode(node)
    ..afterSelection = afterSelection;
  await editorState.apply(transaction);
  return true;
}
