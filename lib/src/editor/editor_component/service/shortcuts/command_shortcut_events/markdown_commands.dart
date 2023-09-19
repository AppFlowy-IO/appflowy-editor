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
  handler: (editorState) => _toggleAttribute(editorState, 'bold'),
);

final CommandShortcutEvent toggleItalicCommand = CommandShortcutEvent(
  key: 'toggle italic',
  command: 'ctrl+i',
  macOSCommand: 'cmd+i',
  handler: (editorState) => _toggleAttribute(editorState, 'italic'),
);

final CommandShortcutEvent toggleUnderlineCommand = CommandShortcutEvent(
  key: 'toggle underline',
  command: 'ctrl+u',
  macOSCommand: 'cmd+u',
  handler: (editorState) => _toggleAttribute(editorState, 'underline'),
);

final CommandShortcutEvent toggleStrikethroughCommand = CommandShortcutEvent(
  key: 'toggle strikethrough',
  command: 'ctrl+shift+s',
  macOSCommand: 'cmd+shift+s',
  handler: (editorState) => _toggleAttribute(editorState, 'strikethrough'),
);

final CommandShortcutEvent toggleCodeCommand = CommandShortcutEvent(
  key: 'toggle code',
  command: 'ctrl+e',
  macOSCommand: 'cmd+e',
  handler: (editorState) => _toggleAttribute(editorState, 'code'),
);

KeyEventResult _toggleAttribute(
  EditorState editorState,
  String key,
) {
  final selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }

  editorState.toggleAttribute(key);

  return KeyEventResult.handled;
}
