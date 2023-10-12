import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart' hide Overlay, OverlayEntry;

typedef ToolbarItemEventHandler = void Function(
  EditorState editorState,
  BuildContext context,
);
typedef ToolbarItemValidator = bool Function(EditorState editorState);
typedef ToolbarItemHighlightCallback = bool Function(EditorState editorState);

class ToolbarItem {
  ToolbarItem({
    required this.id,
    required this.group,
    this.type = 1,
    this.tooltipsMessage = '',
    this.iconBuilder,
    this.validator,
    this.highlightCallback,
    this.handler,
    this.itemBuilder,
    this.isActive,
    this.builder,
  });

  final String id;
  final int group;
  bool Function(EditorState editorState)? isActive;
  final Widget Function(
    BuildContext context,
    EditorState editorState,
    Color highlightColor,
    Color? iconColor,
  )? builder;

  // deprecated
  final int type;
  final String tooltipsMessage;

  final ToolbarItemValidator? validator;

  final Widget Function(bool isHighlight)? iconBuilder;
  final ToolbarItemEventHandler? handler;
  final ToolbarItemHighlightCallback? highlightCallback;

  final Widget Function(BuildContext context, EditorState editorState)?
      itemBuilder;

  factory ToolbarItem.divider() {
    return ToolbarItem(
      id: 'divider',
      type: -1,
      group: -1,
      iconBuilder: (_) => const EditorSvg(name: 'toolbar/divider'),
      validator: (editorState) => true,
      handler: (editorState, context) {},
      highlightCallback: (editorState) => false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is! ToolbarItem) {
      return false;
    }
    if (identical(this, other)) {
      return true;
    }
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}

final Set<String> toolbarItemWhiteList = {
  ParagraphBlockKeys.type,
  NumberedListBlockKeys.type,
  BulletedListBlockKeys.type,
  QuoteBlockKeys.type,
  TodoListBlockKeys.type,
  HeadingBlockKeys.type,
};

bool onlyShowInSingleSelectionAndTextType(EditorState editorState) {
  final selection = editorState.selection;
  if (selection == null || !selection.isSingle) {
    return false;
  }
  final node = editorState.getNodeAtPath(selection.start.path);
  if (node == null) {
    return false;
  }
  return node.delta != null && toolbarItemWhiteList.contains(node.type);
}

bool onlyShowInTextType(EditorState editorState) {
  final selection = editorState.selection;
  if (selection == null) {
    return false;
  }
  final nodes = editorState.getNodesInSelection(selection);
  return nodes.every(
    (element) =>
        element.delta != null && toolbarItemWhiteList.contains(element.type),
  );
}
