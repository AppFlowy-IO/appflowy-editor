import 'package:appflowy_editor/appflowy_editor.dart';

/// format the markdown link syntax to hyperlink
final CharacterShortcutEvent formatMarkdownLinkToLink = CharacterShortcutEvent(
  key: 'format the text surrounded by double asterisks to bold',
  character: ')',
  handler: (editorState) async => handleFormatMarkdownLinkToLink(
    editorState: editorState,
  ),
);

final _linkRegex = RegExp(r'\[([^\]]*)\]\((.*?)\)');

bool handleFormatMarkdownLinkToLink({
  required EditorState editorState,
}) {
  final selection = editorState.selection;
  // if the selection is not collapsed or the cursor is at the first 5 index range, we don't need to format it.
  // we should return false to let the IME handle it.
  if (selection == null || !selection.isCollapsed || selection.end.offset < 6) {
    return false;
  }

  final path = selection.end.path;
  final node = editorState.getNodeAtPath(path);
  final delta = node?.delta;
  // if the node doesn't contain the delta(which means it isn't a text)
  // we don't need to format it.
  if (node == null || delta == null) {
    return false;
  }

  final plainText = '${delta.toPlainText()})';

  // Determine if regex matches the plainText.
  if (!_linkRegex.hasMatch(plainText)) {
    return false;
  }

  final matches = _linkRegex.allMatches(plainText);
  final lastMatch = matches.last;
  final title = lastMatch.group(1);
  final link = lastMatch.group(2);

  // if all the conditions are met, we should format the text to a link.
  final transaction = editorState.transaction
    ..deleteText(
      node,
      lastMatch.start,
      lastMatch.end - lastMatch.start - 1,
    )
    ..insertText(
      node,
      lastMatch.start,
      title!,
      attributes: {
        AppFlowyRichTextKeys.href: link,
      },
    );
  editorState.apply(transaction);

  return true;
}
