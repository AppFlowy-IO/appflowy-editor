import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

const convertibleBlockTypes = [
  'bulleted_list',
  'numbered_list',
  'todo_list',
  'quote',
  'heading',
];

/// Convert to paragraph command.
///
/// - support
///   - desktop
///   - web
///   - mobile
///
/// convert the current block to paragraph.
final CommandShortcutEvent convertToParagraphCommand = CommandShortcutEvent(
  key: 'convert to paragraph',
  command: 'backspace',
  handler: _convertToParagraphCommandHandler,
);

CommandShortcutEventHandler _convertToParagraphCommandHandler = (editorState) {
  final selection = editorState.selection;
  if (selection == null || !selection.isCollapsed) {
    return KeyEventResult.ignored;
  }
  final node = editorState.getNodeAtPath(selection.end.path);
  final delta = node?.delta;
  if (node == null ||
      delta == null ||
      !convertibleBlockTypes.contains(node.type)) {
    return KeyEventResult.ignored;
  }
  final index = delta.prevRunePosition(selection.startIndex);
  if (index >= 0) {
    return KeyEventResult.ignored;
  }
  final transaction = editorState.transaction;
  transaction
    ..insertNode(
      node.path,
      paragraphNode(
        attributes: {
          'delta': delta.toJson(),
        },
        children: node.children,
      ),
      deepCopy: true,
    )
    ..deleteNode(node)
    ..afterSelection = transaction.beforeSelection;
  editorState.apply(transaction);
  return KeyEventResult.handled;
};
