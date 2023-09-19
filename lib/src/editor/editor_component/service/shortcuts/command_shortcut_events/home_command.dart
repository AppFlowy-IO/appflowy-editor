import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// Home key event.
///
/// - support
///   - desktop
///   - web
///
final CommandShortcutEvent homeCommand = CommandShortcutEvent(
  key: 'scroll to the top of the document',
  command: 'ctrl+home',
  macOSCommand: 'home',
  handler: _homeCommandHandler,
);

CommandShortcutEventHandler _homeCommandHandler = (editorState) {
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
