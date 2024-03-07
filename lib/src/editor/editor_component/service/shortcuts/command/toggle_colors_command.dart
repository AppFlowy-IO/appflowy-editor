import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// Toggle Color Commands
///
/// Cmd / Ctrl + Shift + H: toggle highlight color
/// Cmd / Ctrl + Shift + T: toggle text color
/// - support
///   - desktop
///   - web

List<CommandShortcutEvent> toggleColorCommands({
  ToggleColorsStyle? style,
}) =>
    [
      customToggleHighlightCommand(
        style: style ?? ToggleColorsStyle(),
      ),
    ];

class ToggleColorsStyle {
  ToggleColorsStyle({
    this.highlightColor = const Color(0x60FFCE00),
  });

  final Color highlightColor;
}

final CommandShortcutEvent toggleHighlightCommand = CommandShortcutEvent(
  key: 'toggle highlight',
  getDescription: () => AppFlowyEditorL10n.current.cmdToggleHighlight,
  command: 'ctrl+shift+h',
  macOSCommand: 'cmd+shift+h',
  handler: (editorState) => _toggleHighlight(
    editorState,
    style: ToggleColorsStyle(),
  ),
);

CommandShortcutEvent customToggleHighlightCommand({
  required ToggleColorsStyle style,
}) =>
    CommandShortcutEvent(
      key: 'toggle highlight',
      getDescription: () => AppFlowyEditorL10n.current.cmdToggleHighlight,
      command: 'ctrl+shift+h',
      macOSCommand: 'cmd+shift+h',
      handler: (editorState) => _toggleHighlight(editorState, style: style),
    );

KeyEventResult _toggleHighlight(
  EditorState editorState, {
  required ToggleColorsStyle style,
}) {
  if (PlatformExtension.isMobile) {
    assert(false, 'toggle highlight is not supported on mobile platform.');
    return KeyEventResult.ignored;
  }

  final selection = editorState.selection;
  if (selection == null || selection.isCollapsed) {
    return KeyEventResult.ignored;
  }

  //check if already highlighted
  final nodes = editorState.getNodesInSelection(selection);
  final isHighlighted = nodes.allSatisfyInSelection(selection, (delta) {
    return delta.everyAttributes(
      (attributes) => attributes[AppFlowyRichTextKeys.backgroundColor] != null,
    );
  });

  editorState.formatDelta(
    selection,
    {
      AppFlowyRichTextKeys.backgroundColor:
          isHighlighted ? null : style.highlightColor.toHex(),
    },
  );

  return KeyEventResult.handled;
}
