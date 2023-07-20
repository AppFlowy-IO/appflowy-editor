import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// highlight key event.
///
/// - support
///   - desktop
///   - web
///
final CommandShortcutEvent toggleHighlightCommand = CommandShortcutEvent(
  key: 'toggle highlight',
  command: 'ctrl+shift+h',
  macOSCommand: 'cmd+shift+h',
  handler: (editorState) => _toggleHighlight(editorState),
);

KeyEventResult _toggleHighlight(
  EditorState editorState,
) {
  if (PlatformExtension.isMobile) {
    assert(false, 'toggle highlight is not supported on mobile platform.');
    return KeyEventResult.ignored;
  }

  final selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }

  //check if already highlighted
  final nodes = editorState.getNodesInSelection(selection);
  final isHighlight = nodes.allSatisfyInSelection(selection, (delta) {
    return delta.everyAttributes(
      (attributes) => attributes['highlightColor'] != null,
    );
  });

  editorState.formatDelta(
    selection,
    {AppFlowyRichTextKeys.highlightColor: isHighlight ? null : '0XCCCCCC'},
  );

  return KeyEventResult.handled;
}
