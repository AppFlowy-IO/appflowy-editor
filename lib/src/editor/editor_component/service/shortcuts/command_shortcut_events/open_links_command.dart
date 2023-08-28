import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// Option/Alt + Shift + Enter: to open links
/// - support
///   - desktop
///   - web
///
final CommandShortcutEvent openLinksCommand = CommandShortcutEvent(
  key: 'open links',
  command: 'alt+shift+enter',
  handler: _openLinksHandler,
);

KeyEventResult _openLinksHandler(
  EditorState editorState,
) {
  if (PlatformExtension.isMobile) {
    assert(false, 'open links is not supported on mobile platform.');
    return KeyEventResult.ignored;
  }

  final selection = editorState.selection;
  if (selection == null || selection.isCollapsed) {
    return KeyEventResult.ignored;
  }

  final nodes = editorState.getNodesInSelection(selection);

  // A set to store the links which have been opened
  // to prevent opening new tabs for the same link
  Set<String> openedLinks = {};

  for (final node in nodes) {
    for (final operation in node.delta!) {
      final link = operation.attributes?[BuiltInAttributeKey.href];
      if (link == null || openedLinks.contains(link)) continue;

      openedLinks.add(link);
      safeLaunchUrl(link);
    }
  }

  return KeyEventResult.handled;
}
