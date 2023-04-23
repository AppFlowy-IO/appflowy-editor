import 'package:appflowy_editor/appflowy_editor.dart';

/// `*` or `-`  -> bulleted-list
CharacterShortcutEvent formatAsteriskToBulletedList = CharacterShortcutEvent(
  key: 'format asterisk to bulleted list',
  character: ' ',
  handler: (editorState) async =>
      await _formatSymbolToBulletedList(editorState, '*'),
);

CharacterShortcutEvent formatMinusToBulletedList = CharacterShortcutEvent(
  key: 'format minus to bulleted list',
  character: ' ',
  handler: (editorState) async =>
      await _formatSymbolToBulletedList(editorState, '-'),
);

Future<bool> _formatSymbolToBulletedList(
  EditorState editorState,
  String symbol,
) async {
  assert(symbol.length == 1);

  final selection = editorState.selection;
  if (selection == null) {
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
    ..deleteNode(node)
    ..insertNode(
      node.path,
      bulletedListNode,
    )
    ..afterSelection = afterSelection;
  await editorState.apply(transaction);
  return true;
}
