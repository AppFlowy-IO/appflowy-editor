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
  final openedLinks = <String>{};

  for (final node in nodes) {
    final delta = node.delta;
    if (delta == null) {
      continue;
    }

    // Get all links in the node
    final links = delta
        .map<String?>((op) => op.attributes?[AppFlowyRichTextKeys.href])
        .whereNotNull()
        .toSet()
        .difference(openedLinks);

    for (final link in links) {
      safeLaunchUrl(link);
    }

    openedLinks.addAll(links);
  }

  return KeyEventResult.handled;
}
