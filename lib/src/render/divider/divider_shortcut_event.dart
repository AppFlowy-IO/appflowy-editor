import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'divider_node_widget.dart';

// insert divider into a document by typing three minuses.
// ---
ShortcutEvent insertDividerEvent = ShortcutEvent(
  key: 'Divider',
  character: '-',
  handler: _insertDividerHandler,
);

ShortcutEventHandler _insertDividerHandler = (editorState, event) {
  final character = event?.character;
  if (character == null) {
    return KeyEventResult.ignored;
  }

  final selection = editorState.service.selectionService.currentSelection.value;
  final textNodes = editorState.service.selectionService.currentSelectedNodes
      .whereType<TextNode>();
  if (textNodes.length != 1 || selection == null) {
    return KeyEventResult.ignored;
  }

  final textNode = textNodes.first;
  if (textNode.toPlainText() != (character * 2)) {
    return KeyEventResult.ignored;
  }

  final transaction = editorState.transaction
    ..deleteText(textNode, 0, 2) // remove the existing characters.
    ..insertNode(textNode.path, Node(type: kDividerType)) // insert the divider
    ..afterSelection = Selection.single(
      // update selection
      path: textNode.path.next,
      startOffset: 0,
    );
  editorState.apply(transaction);
  return KeyEventResult.handled;
};

SelectionMenuItem dividerMenuItem = SelectionMenuItem(
  name: 'Divider',
  icon: (editorState, onSelected) => Icon(
    Icons.horizontal_rule,
    color: onSelected
        ? editorState.editorStyle.selectionMenuItemSelectedIconColor
        : editorState.editorStyle.selectionMenuItemIconColor,
    size: 18.0,
  ),
  keywords: ['horizontal rule', 'divider'],
  handler: (editorState, _, __) {
    final selection =
        editorState.service.selectionService.currentSelection.value;
    final textNodes = editorState.service.selectionService.currentSelectedNodes
        .whereType<TextNode>();
    if (textNodes.length != 1 || selection == null) {
      return;
    }
    final textNode = textNodes.first;
    // insert the divider at current path if the text node is empty.
    if (textNode.toPlainText().isEmpty) {
      final transaction = editorState.transaction
        ..insertNode(textNode.path, Node(type: kDividerType))
        ..afterSelection = Selection.single(
          path: textNode.path.next,
          startOffset: 0,
        );
      editorState.apply(transaction);
    } else {
      // insert the divider at the path next to current path if the text node is not empty.
      final transaction = editorState.transaction
        ..insertNode(selection.end.path.next, Node(type: kDividerType))
        ..afterSelection = selection;
      editorState.apply(transaction);
    }
  },
);
