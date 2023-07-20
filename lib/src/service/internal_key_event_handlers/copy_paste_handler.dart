import 'package:appflowy_editor/appflowy_editor.dart';

void _pasteSingleLine(
  EditorState editorState,
  Selection selection,
  String line,
) {
  assert(selection.isCollapsed);
  final node = editorState.getNodeAtPath(selection.end.path)!;
  final transaction = editorState.transaction
    ..insertText(node, selection.startIndex, line)
    ..afterSelection = (Selection.collapsed(
      Position(
        path: selection.end.path,
        offset: selection.startIndex + line.length,
      ),
    ));
  editorState.apply(transaction);
}

void _pasteMarkdown(EditorState editorState, String markdown) {
  final selection = editorState.selection;
  if (selection == null) {
    return;
  }

  final lines = markdown.split('\n');

  if (lines.length == 1) {
    _pasteSingleLine(editorState, selection, lines[0]);
    return;
  }

  var path = selection.end.path.next;
  final node = editorState.document.nodeAtPath(selection.end.path);
  final delta = node?.delta;
  if (delta != null && delta.toPlainText().isEmpty) {
    path = selection.end.path;
  }
  final document = markdownToDocument(markdown);
  final transaction = editorState.transaction;
  var afterPath = path;
  for (var i = 0; i < document.root.children.length - 1; i++) {
    afterPath = afterPath.next;
  }
  final offset = document.root.children.lastOrNull?.delta?.length ?? 0;
  transaction
    ..insertNodes(path, document.root.children)
    ..afterSelection = Selection.collapse(
      afterPath,
      offset,
    );
  editorState.apply(transaction);
}

void handlePastePlainText(EditorState editorState, String plainText) {
  final selection = editorState.selection?.normalized;
  if (selection == null) {
    return;
  }

  final lines = plainText
      .split("\n")
      .map((e) => e.replaceAll(RegExp(r'\r'), ""))
      .toList();

  if (lines.isEmpty) {
    return;
  } else if (lines.length == 1) {
    // single line
    _pasteSingleLine(editorState, selection, lines.first);
  } else {
    _pasteMarkdown(editorState, plainText);
  }
}
