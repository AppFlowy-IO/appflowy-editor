import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// Page up key event.
///
/// - support
///   - desktop
///   - web
///
final CommandShortcutEvent pageUpCommand = CommandShortcutEvent(
  key: 'scroll one page up',
  command: 'page up',
  handler: _pageUpCommandHandler,
);

CommandShortcutEventHandler _pageUpCommandHandler = (editorState) {
  if (PlatformExtension.isMobile) {
    assert(false, 'pageUpCommand is not supported on mobile platform.');
    return KeyEventResult.ignored;
  }
  final scrollService = editorState.service.scrollService;
  if (scrollService == null) {
    return KeyEventResult.ignored;
  }

  final scrollHeight = scrollService.onePageHeight;
  final dy = scrollService.dy;
  if (dy <= 0 || scrollHeight == null) {
    return KeyEventResult.ignored;
  }
  scrollService.scrollTo(
    dy - scrollHeight,
    duration: const Duration(milliseconds: 150),
  );
  return KeyEventResult.handled;
};
