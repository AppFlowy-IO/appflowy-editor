import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/infra/clipboard.dart';
import 'package:appflowy_editor/src/service/internal_key_event_handlers/copy_paste_handler.dart';
import 'package:flutter/material.dart';

final List<CommandShortcutEvent> pasteCommands = [
  pasteCommand,
  pasteTextWithoutFormattingCommand,
];

/// Paste.
///
/// - support
///   - desktop
///   - web
///
final CommandShortcutEvent pasteCommand = CommandShortcutEvent(
  key: 'paste the content',
  command: 'ctrl+v',
  macOSCommand: 'cmd+v',
  handler: _pasteCommandHandler,
);

final CommandShortcutEvent pasteTextWithoutFormattingCommand =
    CommandShortcutEvent(
  key: 'paste the content',
  command: 'ctrl+shift+v',
  macOSCommand: 'cmd+shift+v',
  handler: _pasteTextWithoutFormattingCommandHandler,
);

CommandShortcutEventHandler _pasteTextWithoutFormattingCommandHandler =
    (editorState) {
  if (PlatformExtension.isMobile) {
    assert(
      false,
      'pasteTextWithoutFormattingCommand is not supported on mobile platform.',
    );
    return KeyEventResult.ignored;
  }

  var selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }

  // delete the selection first.
  if (!selection.isCollapsed) {
    editorState.deleteSelection(selection);
  }

  // fetch selection again.
  selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.skipRemainingHandlers;
  }
  assert(selection.isCollapsed);

  () async {
    final data = await AppFlowyClipboard.getData();
    final text = data.text;
    if (text != null && text.isNotEmpty) {
      handlePastePlainText(editorState, data.text!);
    }
  }();

  return KeyEventResult.handled;
};

CommandShortcutEventHandler _pasteCommandHandler = (editorState) {
  if (PlatformExtension.isMobile) {
    assert(false, 'pasteCommand is not supported on mobile platform.');
    return KeyEventResult.ignored;
  }

  var selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }

  // delete the selection first.
  if (!selection.isCollapsed) {
    editorState.deleteSelection(selection);
  }

  // fetch selection again.
  selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.skipRemainingHandlers;
  }
  assert(selection.isCollapsed);

  // TODO: paste the rich text.
  () async {
    final data = await AppFlowyClipboard.getData();
    final text = data.text;
    final html = data.html;
    if (html != null && html.isNotEmpty) {
      final nodes = htmlToDocument(html).root.children;
      final transaction = editorState.transaction
        ..insertNodes(selection!.end.path, nodes);
      await editorState.apply(transaction);
    } else if (text != null && text.isNotEmpty) {
      handlePastePlainText(editorState, data.text!);
    }
  }();

  return KeyEventResult.handled;
};
