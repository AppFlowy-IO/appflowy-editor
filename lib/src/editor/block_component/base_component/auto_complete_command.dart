import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

// Add your custom block keys if it supports auto complete
final autoCompletableBlockTypes = {
  ParagraphBlockKeys.type,
  NumberedListBlockKeys.type,
  TodoListBlockKeys.type,
  BulletedListBlockKeys.type,
  QuoteBlockKeys.type,
  HeadingBlockKeys.type,
};

/// Auto complete the current block
///
/// - support
///   - desktop
///   - web
///
final CommandShortcutEvent tabToAutoCompleteCommand = CommandShortcutEvent(
  key: 'tab to auto complete',
  getDescription: () => 'Tab to auto complete',
  command: 'tab',
  handler: _tabToAutoCompleteCommandHandler,
);

CommandShortcutEventHandler _tabToAutoCompleteCommandHandler = (editorState) {
  final selection = editorState.selection;
  if (selection == null || !selection.isCollapsed) {
    return KeyEventResult.ignored;
  }

  final context = editorState.document.root.context;
  final node = editorState.getNodeAtPath(selection.end.path);
  final delta = node?.delta;

  // Now, this command only support auto complete the text if the cursor is at the end of the block
  if (context == null ||
      node == null ||
      !autoCompletableBlockTypes.contains(node.type) ||
      delta == null ||
      selection.endIndex != delta.length) {
    return KeyEventResult.ignored;
  }

  // Support async auto complete text provider in the future
  final autoCompleteText = editorState.autoCompleteTextProvider?.call(
    context,
    node,
    null,
  );
  if (autoCompleteText == null || autoCompleteText.isEmpty) {
    return KeyEventResult.ignored;
  }

  final transaction = editorState.transaction
    ..insertText(
      node,
      selection.endIndex,
      autoCompleteText,
    );
  editorState.apply(transaction);

  return KeyEventResult.handled;
};
