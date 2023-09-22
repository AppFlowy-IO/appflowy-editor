import 'dart:math';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// Page down key event.
///
/// - support
///   - desktop
///   - web
///
final CommandShortcutEvent pageDownCommand = CommandShortcutEvent(
  key: 'scroll one page down',
  command: 'page down',
  handler: _pageUpCommandHandler,
);

CommandShortcutEventHandler _pageUpCommandHandler = (editorState) {
  final scrollService = editorState.service.scrollService;
  if (scrollService == null) {
    return KeyEventResult.ignored;
  }

  final scrollHeight = scrollService.onePageHeight;
  final dy = max(0, scrollService.dy);
  if (scrollHeight == null) {
    return KeyEventResult.ignored;
  }
  scrollService.scrollTo(
    dy + scrollHeight,
    duration: const Duration(milliseconds: 150),
  );
  return KeyEventResult.handled;
};
