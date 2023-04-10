import 'package:appflowy_editor/src/core/document/node.dart';
import 'package:appflowy_editor/src/extensions/node_extensions.dart';
import 'package:appflowy_editor/src/render/find_replace_menu/find_menu_service.dart';
import 'package:appflowy_editor/src/service/shortcut_event/shortcut_event_handler.dart';
import 'package:flutter/material.dart';

FindReplaceService? _findMenuService;
ShortcutEventHandler findShortcutHandler = (editorState, event) {
  final textNodes = editorState.service.selectionService.currentSelectedNodes
      .whereType<TextNode>();
  if (textNodes.length != 1) {
    return KeyEventResult.ignored;
  }

  final selection = editorState.service.selectionService.currentSelection.value;
  final textNode = textNodes.first;
  final context = textNode.context;
  final selectable = textNode.selectable;
  if (selection == null || context == null || selectable == null) {
    return KeyEventResult.ignored;
  }

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _findMenuService =
        FindReplaceMenu(context: context, editorState: editorState);
    _findMenuService?.show();
  });

  return KeyEventResult.handled;
};
