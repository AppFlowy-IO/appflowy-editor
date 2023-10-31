import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// Option/Alt + Enter: to open inline link
/// - support
///   - desktop
///   - web
///
final CommandShortcutEvent openInlineLinkCommand = CommandShortcutEvent(
  key: 'open inline link',
  command: 'alt+enter',
  handler: _openInlineLink,
);

KeyEventResult _openInlineLink(
  EditorState editorState,
) {
  //TODO:If selection is collapsed, isHref is false.
  final selection = editorState.selection;
  if (selection == null || selection.isCollapsed) {
    return KeyEventResult.ignored;
  }

  final nodes = editorState.getNodesInSelection(selection);

  final isHref = nodes.allSatisfyInSelection(selection, (delta) {
    return delta.everyAttributes(
      (attributes) => attributes[BuiltInAttributeKey.href] != null,
    );
  });

  String? linkText;
  if (isHref) {
    linkText = editorState.getDeltaAttributeValueInSelection(
      BuiltInAttributeKey.href,
      selection,
    );
  }

  if (linkText != null) {
    safeLaunchUrl(linkText);
  }

  return KeyEventResult.handled;
}
