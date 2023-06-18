import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// Enter and Option/Alt: open a link in browser
/// - support
///   - desktop
///   - web
final CommandShortcutEvent showLinkMenuCommand = CommandShortcutEvent(
  key: 'link menu',
  command: 'alt+enter',
  handler: (editorState) => _openLink(editorState),
);

KeyEventResult _openLink(
  EditorState editorState,
) {
  if (PlatformExtension.isMobile) {
    assert(false, 'open link is not supported on mobile platform.');
    return KeyEventResult.ignored;
  }

  final selection = editorState.selection;
  if (selection == null || selection.isCollapsed) {
    return KeyEventResult.ignored;
  }
  final context =
      editorState.getNodeAtPath(selection.end.path)?.key.currentContext;
  if (context == null) {
    return KeyEventResult.ignored;
  }
  final nodes = editorState.getNodesInSelection(selection);
  final isHref = nodes.allSatisfyInSelection(selection, (delta) {
    return delta.everyAttributes(
      (attributes) => attributes['href'] != null,
    );
  });

  String? linkText;
  if (isHref) {
    linkText = editorState.getDeltaAttributeValueInSelection(
      BuiltInAttributeKey.href,
      selection,
    );
  }

  if (linkText == null || linkText.isEmpty) {
    return KeyEventResult.ignored;
  }

  safeLaunchUrl(linkText);
  return KeyEventResult.handled;
}
