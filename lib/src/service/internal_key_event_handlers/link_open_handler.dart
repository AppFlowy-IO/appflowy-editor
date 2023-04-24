import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

ShortcutEventHandler linkOpenHandler = (editorState, event) {
  final selection = editorState.service.selectionService.currentSelection.value;
  final node = editorState.service.selectionService.currentSelectedNodes;
  if (selection == null || node.isEmpty || node.first is! TextNode) {
    return KeyEventResult.ignored;
  }

  final textNode = node.first as TextNode;
  String? linkText;
  if (textNode.allSatisfyLinkInSelection(selection)) {
    linkText = textNode.getAttributeInSelection<String>(
      selection,
      BuiltInAttributeKey.href,
    );
  } else {
    return KeyEventResult.handled;
  }

  if (linkText == null) {
    return KeyEventResult.handled;
  }

  launchUrl(linkText);
  return KeyEventResult.handled;
};

Future<void> launchUrl(String linkText) async {
  await safeLaunchUrl(linkText);
}
