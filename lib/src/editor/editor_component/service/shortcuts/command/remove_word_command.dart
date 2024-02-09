import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// Backspace key event.
///
/// - support
///   - desktop
///   - web

final CommandShortcutEvent deleteLeftWordCommand = CommandShortcutEvent(
  key: 'delete the left word',
  getDescription: () => AppFlowyEditorL10n.current.cmdDeleteWordLeft,
  command: 'ctrl+backspace',
  macOSCommand: 'alt+backspace',
  handler: _deleteLeftWordCommandHandler,
);

final CommandShortcutEvent deleteRightWordCommand = CommandShortcutEvent(
  key: 'delete the right word',
  getDescription: () => AppFlowyEditorL10n.current.cmdDeleteWordRight,
  command: 'ctrl+delete',
  macOSCommand: 'alt+delete',
  handler: _deleteRightWordCommandHandler,
);

CommandShortcutEventHandler _deleteLeftWordCommandHandler = (editorState) {
  final selection = editorState.selection;
  if (selection == null || !selection.isSingle) {
    return KeyEventResult.ignored;
  }

  final node = editorState.getNodeAtPath(selection.end.path);
  final delta = node?.delta;
  if (node == null || delta == null) {
    return KeyEventResult.ignored;
  }

  // we store the position where the current word starts.
  var startOfWord = selection.end.moveHorizontal(
    editorState,
    selectionRange: SelectionRange.word,
  );

  if (startOfWord == null) {
    return KeyEventResult.ignored;
  }

  //check if the selected word is whitespace
  final selectedWord = delta.toPlainText().substring(
        startOfWord.offset,
        selection.end.offset,
      );

  // if it is whitespace then we have to update the selection to include
  //  the left word from the whitespace.
  if (selectedWord.trim().isEmpty) {
    //make a new selection from the left of the whitespace.
    final newSelection = Selection.single(
      path: startOfWord.path,
      startOffset: startOfWord.offset,
    );

    //we need to check if this position is not null
    final newStartOfWord = newSelection.end.moveHorizontal(
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
    node,
    startOfWord.offset,
    selection.end.offset - startOfWord.offset,
  );

  editorState.apply(transaction);

  return KeyEventResult.handled;
};

CommandShortcutEventHandler _deleteRightWordCommandHandler = (editorState) {
  final selection = editorState.selection;
  if (selection == null || !selection.isSingle) {
    return KeyEventResult.ignored;
  }

  final node = editorState.getNodeAtPath(selection.end.path);
  final delta = node?.delta;
  if (node == null || delta == null) {
    return KeyEventResult.ignored;
  }

  // we store the position where the current word ends.
  var endOfWord = selection.end.moveHorizontal(
    editorState,
    forward: false,
    selectionRange: SelectionRange.word,
  );

  if (endOfWord == null) {
    return KeyEventResult.ignored;
  }

  //check if the selected word is whitespace
  final selectedLine = delta.toPlainText();
  final selectedWord = selectedLine.substring(
    selection.end.offset,
    endOfWord.offset,
  );

  // if it is whitespace then we have to update the selection to include
  //  the left word from the whitespace.
  if (selectedWord.trim().isEmpty) {
    //make a new selection to the right of the whitespace.
    final newSelection = Selection.single(
      path: endOfWord.path,
      startOffset: endOfWord.offset,
    );

    //we need to check if this position is not null
    final newEndOfWord = newSelection.end.moveHorizontal(
      editorState,
      forward: false,
      selectionRange: SelectionRange.word,
    );

    //this handles the edge case where the textNode only consists single space.
    if (newEndOfWord != null) {
      endOfWord = newEndOfWord;
    }
  }

  final transaction = editorState.transaction;
  transaction.deleteText(
    node,
    selection.end.offset,
    endOfWord.offset - selection.end.offset,
  );

  editorState.apply(transaction);

  return KeyEventResult.handled;
};
