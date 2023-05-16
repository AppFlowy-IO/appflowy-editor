import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/infra/clipboard.dart';
import 'package:flutter/material.dart';

/// End key event.
///
/// - support
///   - desktop
///   - web
///
final CommandShortcutEvent copyCommand = CommandShortcutEvent(
  key: 'copy the selected content',
  command: 'ctrl+c',
  macOSCommand: 'cmd+c',
  handler: _copyCommandHandler,
);

CommandShortcutEventHandler _copyCommandHandler = (editorState) {
  if (PlatformExtension.isMobile) {
    assert(false, 'copyCommand is not supported on mobile platform.');
    return KeyEventResult.ignored;
  }

  var selection = editorState.selection?.normalized;
  if (selection == null || selection.isCollapsed) {
    return KeyEventResult.ignored;
  }

  // plain text.
  final text = editorState.getTextInSelection(selection).join('\n');

  // rich text.
  final nodes = editorState.getNodesInSelection(selection);
  final html = NodesToHTMLConverter(
    nodes: nodes,
    startOffset: selection.startIndex,
    endOffset: selection.endIndex,
  ).toHTMLString();

  AppFlowyClipboard.setData(
    text: text,
    html: html,
  );

  return KeyEventResult.handled;
};
