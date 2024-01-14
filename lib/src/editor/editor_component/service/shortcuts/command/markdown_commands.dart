import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

final List<CommandShortcutEvent> toggleMarkdownCommands = [
  toggleBoldCommand,
  toggleItalicCommand,
  toggleUnderlineCommand,
  toggleStrikethroughCommand,
  toggleCodeCommand,
];

/// Markdown key event.
///
/// Cmd / Ctrl + B: toggle bold
/// Cmd / Ctrl + I: toggle italic
/// Cmd / Ctrl + U: toggle underline
/// Cmd / Ctrl + Shift + S: toggle strikethrough
/// Cmd / Ctrl + E: code
/// - support
///   - desktop
///   - web
///
final CommandShortcutEvent toggleBoldCommand = CommandShortcutEvent(
  key: 'toggle bold',
  command: 'ctrl+b',
  macOSCommand: 'cmd+b',
  handler: (editorState) => _toggleAttribute(
    editorState,
    AppFlowyRichTextKeys.bold,
  ),
);

final CommandShortcutEvent toggleItalicCommand = CommandShortcutEvent(
  key: 'toggle italic',
  command: 'ctrl+i',
  macOSCommand: 'cmd+i',
  handler: (editorState) => _toggleAttribute(
    editorState,
    AppFlowyRichTextKeys.italic,
  ),
);

final CommandShortcutEvent toggleUnderlineCommand = CommandShortcutEvent(
  key: 'toggle underline',
  command: 'ctrl+u',
  macOSCommand: 'cmd+u',
  handler: (editorState) => _toggleAttribute(
    editorState,
    AppFlowyRichTextKeys.underline,
  ),
);

final CommandShortcutEvent toggleStrikethroughCommand = CommandShortcutEvent(
  key: 'toggle strikethrough',
  command: 'ctrl+shift+s',
  macOSCommand: 'cmd+shift+s',
  handler: (editorState) => _toggleAttribute(
    editorState,
    AppFlowyRichTextKeys.strikethrough,
  ),
);

final CommandShortcutEvent toggleCodeCommand = CommandShortcutEvent(
  key: 'toggle code',
  command: 'ctrl+e',
  macOSCommand: 'cmd+e',
  handler: (editorState) => _toggleAttribute(
    editorState,
    AppFlowyRichTextKeys.code,
  ),
);

KeyEventResult _toggleAttribute(
  EditorState editorState,
  String key,
) {
  //NOTE: This is a fix for vim  mode. Some keys are conflicting
  if (editorState.mode == VimModes.insertMode || editorState.vimMode == false) {
    final selection = editorState.selection;
    if (selection == null) {
      return KeyEventResult.ignored;
    }

    editorState.toggleAttribute(key);

    return KeyEventResult.handled;
  }
  return KeyEventResult.ignored;
}
