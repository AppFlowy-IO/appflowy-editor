import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

/// Select all key event.
///
/// - support
///   - desktop
///   - web
///
final CommandShortcutEvent selectAllCommand = CommandShortcutEvent(
  key: 'select all the selectable content',
  command: 'ctrl+a',
  macOSCommand: 'cmd+a',
  handler: _selectAllCommandHandler,
);

CommandShortcutEventHandler _selectAllCommandHandler = (editorState) {
  if (PlatformExtension.isMobile) {
    assert(false, 'selectAllCommand is not supported on mobile platform.');
    return KeyEventResult.ignored;
  }
  if (editorState.document.root.children.isEmpty) {
    return KeyEventResult.handled;
  }
  final firstSelectable = editorState.document.root.children
      .firstWhereOrNull(
        (element) => element.selectable != null,
      )
      ?.selectable;
  final lastSelectable = editorState.document.root.children
      .lastWhereOrNull(
        (element) => element.selectable != null,
      )
      ?.selectable;
  if (firstSelectable == null || lastSelectable == null) {
    return KeyEventResult.handled;
  }
  editorState.updateSelectionWithReason(
    Selection(start: firstSelectable.start(), end: lastSelectable.end()),
  );
  return KeyEventResult.handled;
};
