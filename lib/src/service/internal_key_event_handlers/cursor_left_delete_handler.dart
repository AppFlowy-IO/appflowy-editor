import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

ShortcutEventHandler cursorLeftWordDelete = (editorState, event) {
  final textNodes = editorState.service.selectionService.currentSelectedNodes
      .whereType<TextNode>();
  final selection = editorState.service.selectionService.currentSelection.value;

  if (textNodes.isEmpty || selection == null) {
    return KeyEventResult.ignored;
  }

  final textNode = textNodes.first;

  //we store the position where the current word starts.
  var startOfWord =
      selection.end.goLeft(editorState, selectionRange: SelectionRange.word);

  if (startOfWord == null) {
    return KeyEventResult.ignored;
  }

  //check if the selected word is whitespace
  final selectedWord = textNode
      .toPlainText()
      .substring(startOfWord.offset, selection.end.offset);

  //if it is whitespace then we have to update the selection to include
  //the left word from the whitespace.
  if (selectedWord.trim().isEmpty) {
    //make a new selection from the left of the whitespace.
    final newSelection = Selection.single(
      path: startOfWord.path,
      startOffset: startOfWord.offset,
    );

    //we need to check if this position is not null
    final newStartOfWord = newSelection.end.goLeft(
      editorState,
      selectionRange: SelectionRange.word,
    );

    //this handles the edge case where the textNode only consists single space.
    if (newStartOfWord != null) {
      startOfWord = newStartOfWord;
    }
  }

  final transaction = editorState.transaction;
  transaction.deleteText(
    textNode,
    startOfWord.offset,
    selection.end.offset - startOfWord.offset,
  );

  editorState.apply(transaction);

  return KeyEventResult.handled;
};

ShortcutEventHandler cursorLeftSentenceDelete = (editorState, event) {
  final nodes = editorState.service.selectionService.currentSelectedNodes;
  final selection = editorState.service.selectionService.currentSelection.value;
  if (nodes.isEmpty || selection == null) {
    return KeyEventResult.ignored;
  }

  if (nodes.length == 1 && nodes.first is TextNode) {
    final textNode = nodes.first as TextNode;
    if (textNode.toPlainText().isEmpty) {
      return KeyEventResult.ignored;
    }
  }

  if (selection.isCollapsed) {
    final deleteTransaction = editorState.transaction;
    deleteTransaction.deleteText(
      nodes.first as TextNode,
      0,
      selection.end.offset,
    );
    editorState.apply(deleteTransaction, withUpdateCursor: true);
  }

  return KeyEventResult.handled;
};
