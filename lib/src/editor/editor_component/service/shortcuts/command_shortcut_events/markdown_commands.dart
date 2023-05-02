import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// Markdown key event.
///
/// Cmd / Ctrl + B: toggle bold
/// Cmd / Ctrl + I: toggle italic
/// Cmd / Ctrl + U: toggle underline
/// Cmd / Ctrl + Shift + S: toggle strikethrough
/// Cmd / Ctrl + Shift + H: toggle highlight
/// Cmd / Ctrl + k: link
///
/// - support
///   - desktop
///   - web
///
CommandShortcutEvent toggleBoldCommand = CommandShortcutEvent(
  key: 'toggle bold',
  command: 'ctrl+b',
  macOSCommand: 'cmd+b',
  handler: _toggleBoldCommandHandler,
);

CommandShortcutEventHandler _toggleBoldCommandHandler = (editorState) {
  if (PlatformExtension.isMobile) {
    assert(false, 'homeCommand is not supported on mobile platform.');
    return KeyEventResult.ignored;
  }
  final scrollService = editorState.service.scrollService;
  if (scrollService == null) {
    return KeyEventResult.ignored;
  }
  // scroll the document to the top
  scrollService.scrollTo(
    scrollService.minScrollExtent,
    duration: const Duration(milliseconds: 150),
  );
  return KeyEventResult.handled;
};
