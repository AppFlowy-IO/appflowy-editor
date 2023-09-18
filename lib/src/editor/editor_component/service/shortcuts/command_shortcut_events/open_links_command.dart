import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:collection/collection.dart';
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
  final selection = editorState.selection;
  if (selection == null || selection.isCollapsed) {
    return KeyEventResult.ignored;
  }

  final nodes = editorState.getNodesInSelection(selection);

  // A set to store the links which should be opened
  final links = nodes
      .map((node) => node.delta)
      .whereNotNull()
      .expand(
        (node) => node.map<String?>(
          (op) => op.attributes?[AppFlowyRichTextKeys.href],
        ),
      )
      .whereNotNull()
      .toSet();

  for (final link in links) {
    safeLaunchUrl(link);
  }

  return KeyEventResult.handled;
}
