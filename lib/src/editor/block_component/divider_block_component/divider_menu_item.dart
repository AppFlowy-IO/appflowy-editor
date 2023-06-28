import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/base_component/selection_menu/selection_menu.dart';
import 'package:flutter/material.dart';

SelectionMenuItem dividerMenuItem = SelectionMenuItem(
  name: 'Divider',
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
      ..afterSelection = Selection.collapse(insertedPath.next, 0);
    editorState.apply(transaction);
  },
);
