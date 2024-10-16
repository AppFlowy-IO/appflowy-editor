import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final List<CommandShortcutEvent> toggleHeadingCommands = [
  toggleH1,
  toggleH2,
  toggleH3,
  toggleBody,
];

/// Markdown key event.
///
/// Cmd / Ctrl + Shift + T: toggle H1
/// Cmd / Ctrl + Shift + G: toggle H2
/// Cmd / Ctrl + Shift + J: toggle H3
/// Cmd / Ctrl + Shift + B: toggle Body
/// - support
///   - desktop
///   - web
///
final CommandShortcutEvent toggleH1 = CommandShortcutEvent(
  key: 'toggle H1',
  getDescription: () => AppFlowyEditorL10n.current.cmdToggleH1,
  command: 'ctrl+shift+t',
  macOSCommand: 'cmd+shift+t',
  handler: (editorState) => _toggleAttribute(
    editorState,
    1,
  ),
);

final CommandShortcutEvent toggleH2 = CommandShortcutEvent(
  key: 'toggle H2',
  getDescription: () => AppFlowyEditorL10n.current.cmdToggleH2,
  command: 'ctrl+shift+g',
  macOSCommand: 'cmd+shift+g',
  handler: (editorState) => _toggleAttribute(
    editorState,
    2,
  ),
);

final CommandShortcutEvent toggleH3 = CommandShortcutEvent(
  key: 'toggle H3',
  getDescription: () => AppFlowyEditorL10n.current.cmdToggleH3,
  command: 'ctrl+shift+j',
  macOSCommand: 'cmd+shift+j',
  handler: (editorState) => _toggleAttribute(
    editorState,
    3,
  ),
);

final CommandShortcutEvent toggleBody = CommandShortcutEvent(
  key: 'toggle Body',
  getDescription: () => AppFlowyEditorL10n.current.cmdToggleBody,
  command: 'ctrl+shift+b',
  macOSCommand: 'cmd+shift+b',
  handler: (editorState) => _toggleAttribute(editorState, 1, true),
);

KeyEventResult _toggleAttribute(
  EditorState editorState,
  int? level, [
  bool? isBody,
]) {
  final selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }

  final node = editorState.getNodeAtPath(selection.start.path)!;
  bool isHeading = isBody ??
      node.type == HeadingBlockKeys.type &&
          node.attributes[HeadingBlockKeys.level] == level;

  final delta = (node.delta ?? Delta()).toJson();

  editorState.formatNode(
    selection,
    (node) => node.copyWith(
      type: isHeading ? ParagraphBlockKeys.type : HeadingBlockKeys.type,
      attributes: {
        HeadingBlockKeys.level: level,
        blockComponentBackgroundColor:
            node.attributes[blockComponentBackgroundColor],
        blockComponentTextDirection:
            node.attributes[blockComponentTextDirection],
        blockComponentDelta: delta,
      },
    ),
  );

  return KeyEventResult.handled;
}
