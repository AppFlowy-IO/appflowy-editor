import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// End key event.
///
/// - support
///   - desktop
///   - web
///
final CommandShortcutEvent endCommand = CommandShortcutEvent(
  key: 'scroll to the bottom of the document',
  command: 'ctrl+end',
  macOSCommand: 'end',
  handler: _endCommandHandler,
);

CommandShortcutEventHandler _endCommandHandler = (editorState) {
  final scrollService = editorState.service.scrollService;
  if (scrollService == null) {
    return KeyEventResult.ignored;
  }
  // scroll the document to the bottom
  scrollService.scrollTo(
    scrollService.maxScrollExtent,
    duration: const Duration(milliseconds: 150),
  );
  return KeyEventResult.handled;
};
