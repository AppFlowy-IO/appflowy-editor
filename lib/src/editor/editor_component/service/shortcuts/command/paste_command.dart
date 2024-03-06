import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/shortcuts/command/copy_paste_extension.dart';
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
  getDescription: () => AppFlowyEditorL10n.current.cmdPasteContent,
  command: 'ctrl+v',
  macOSCommand: 'cmd+v',
  handler: _pasteCommandHandler,
);

final CommandShortcutEvent pasteTextWithoutFormattingCommand =
    CommandShortcutEvent(
  key: 'paste the content as plain text',
  getDescription: () => AppFlowyEditorL10n.current.cmdPasteContentAsPlainText,
  command: 'ctrl+shift+v',
  macOSCommand: 'cmd+shift+v',
  handler: _pasteTextWithoutFormattingCommandHandler,
);

CommandShortcutEventHandler _pasteTextWithoutFormattingCommandHandler =
    (editorState) {
  final selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }

  () async {
    final data = await AppFlowyClipboard.getData();
    final text = data.text;
    if (text != null && text.isNotEmpty) {
      await editorState.deleteSelectionIfNeeded();
      await editorState.pastePlainText(text);
    }
  }();

  return KeyEventResult.handled;
};

CommandShortcutEventHandler _pasteCommandHandler = (editorState) {
  final selection = editorState.selection;
  if (selection == null) {
    return KeyEventResult.ignored;
  }

  () async {
    final data = await AppFlowyClipboard.getData();
    final text = data.text;
    final html = data.html;
    if (html != null && html.isNotEmpty) {
      await editorState.deleteSelectionIfNeeded();
      // if the html is pasted successfully, then return
      // otherwise, paste the plain text
      if (await editorState.pasteHtml(html)) {
        return;
      }
    }

    if (text != null && text.isNotEmpty) {
      await editorState.deleteSelectionIfNeeded();
      editorState.pastePlainText(text);
    }
  }();

  return KeyEventResult.handled;
};

RegExp _hrefRegex = RegExp(
  r'https?://(?:www\.)?[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}(?:/[^\s]*)?',
);

extension on EditorState {
  Future<bool> pasteHtml(String html) async {
    final nodes = htmlToDocument(html).root.children.toList();
    // remove the front and back empty line
    while (nodes.isNotEmpty && nodes.first.delta?.isEmpty == true) {
      nodes.removeAt(0);
    }
    while (nodes.isNotEmpty && nodes.last.delta?.isEmpty == true) {
      nodes.removeLast();
    }
    if (nodes.isEmpty) {
      return false;
    }
    if (nodes.length == 1) {
      await pasteSingleLineNode(nodes.first);
    } else {
      await pasteMultiLineNodes(nodes.toList());
    }
    return true;
  }

  Future<void> pastePlainText(String plainText) async {
    if (await pasteHtmlIfAvailable(plainText)) {
      return;
    }

    await deleteSelectionIfNeeded();

    final nodes = plainText
        .split('\n')
        .map(
          (paragraph) => paragraph
            ..replaceAll(r'\r', '')
            ..trimRight(),
        )
        .map((paragraph) {
          Delta delta = Delta();
          if (_hrefRegex.hasMatch(paragraph)) {
            final firstMatch = _hrefRegex.firstMatch(paragraph);
            if (firstMatch != null) {
              int startPos = firstMatch.start;
              int endPos = firstMatch.end;
              final String? url = firstMatch.group(0);
              if (url != null) {
                /// insert the text before the link
                if (startPos > 0) {
                  delta.insert(paragraph.substring(0, startPos));
                }

                /// insert the link
                delta.insert(
                  paragraph.substring(startPos, endPos),
                  attributes: {AppFlowyRichTextKeys.href: url},
                );

                /// insert the text after the link
                if (endPos < paragraph.length) {
                  delta.insert(paragraph.substring(endPos));
                }
              }
            }
          } else {
            delta.insert(paragraph);
          }
          return delta;
        })
        .map((paragraph) => paragraphNode(delta: paragraph))
        .toList();

    if (nodes.isEmpty) {
      return;
    }
    if (nodes.length == 1) {
      await pasteSingleLineNode(nodes.first);
    } else {
      await pasteMultiLineNodes(nodes.toList());
    }
  }

  Future<bool> pasteHtmlIfAvailable(String plainText) async {
    final selection = this.selection;
    if (selection == null ||
        !selection.isSingle ||
        selection.isCollapsed ||
        !_hrefRegex.hasMatch(plainText)) {
      return false;
    }

    final node = getNodeAtPath(selection.start.path);
    if (node == null) {
      return false;
    }

    final transaction = this.transaction;
    transaction.formatText(node, selection.startIndex, selection.length, {
      AppFlowyRichTextKeys.href: plainText,
    });
    await apply(transaction);
    return true;
  }
}
