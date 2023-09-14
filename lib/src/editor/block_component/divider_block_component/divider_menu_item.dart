import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

SelectionMenuItem dividerMenuItem = SelectionMenuItem(
  name: AppFlowyEditorLocalizations.current.divider,
  icon: (editorState, isSelected, style) => SelectionMenuIconWidget(
    icon: Icons.horizontal_rule,
    isSelected: isSelected,
    style: style,
  ),
  keywords: ['horizontal rule', 'divider'],
  handler: (editorState, _, __) {
    final selection = editorState.selection;
    if (selection == null || !selection.isCollapsed) {
      return;
    }
    final path = selection.end.path;
    final node = editorState.getNodeAtPath(path);
    final delta = node?.delta;
    if (node == null || delta == null) {
      return;
    }
    final insertedPath = delta.isEmpty ? path : path.next;
    final transaction = editorState.transaction
      ..insertNode(insertedPath, dividerNode())
      ..insertNode(insertedPath, paragraphNode())
      ..afterSelection = Selection.collapsed(Position(path: insertedPath.next));
    editorState.apply(transaction);
  },
);
