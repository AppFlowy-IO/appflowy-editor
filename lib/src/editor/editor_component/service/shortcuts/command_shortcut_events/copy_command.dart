import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// Copy.
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
  final selection = editorState.selection?.normalized;
  if (selection == null || selection.isCollapsed) {
    return KeyEventResult.ignored;
  }

  // plain text.
  final text = editorState.getTextInSelection(selection).join('\n');

  // html
  final nodes = editorState.getSelectedNodes(
    selection: selection,
  );
  final document = Document.blank()..insert([0], nodes);
  final html = documentToHTML(document);

  () async {
    await AppFlowyClipboard.setData(
      text: text.isEmpty ? null : text,
      html: html.isEmpty ? null : html,
    );
  }();

  return KeyEventResult.handled;
};
