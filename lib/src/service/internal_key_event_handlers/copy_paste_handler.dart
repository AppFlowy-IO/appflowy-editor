import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/widgets.dart';

int _textLengthOfNode(Node node) {
  if (node.delta != null) {
    return node.delta!.length;
  }

  return 0;
}

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

void pasteHTML(EditorState editorState, String html) {
  final selection = editorState.selection?.normalized;
  if (selection == null) {
    return;
  }

  assert(selection.isCollapsed);

  Log.keyboard.debug('paste html: $html');
  final htmltoNodes = htmlToDocument(html);

  if (htmltoNodes.isEmpty) {
    return;
  }

  _pasteMultipleLinesInText(
    editorState,
    selection.start.offset,
    htmltoNodes.root.children.toList(),
  );
}

Selection _computeSelectionAfterPasteMultipleNodes(
  EditorState editorState,
  List<Node> nodes,
) {
  final currentSelection = editorState.selection!;
  final currentCursor = currentSelection.start;
  final currentPath = [...currentCursor.path];
  currentPath[currentPath.length - 1] += nodes.length;
  int lenOfLastNode = _textLengthOfNode(nodes.last);
  return Selection.collapsed(
    Position(path: currentPath, offset: lenOfLastNode),
  );
}

void handleCopy(EditorState editorState) async {
  final selection = editorState.selection?.normalized;
  if (selection == null || selection.isCollapsed) {
    return;
  }
  final text = editorState.getTextInSelection(selection).join('\n');
  final nodes = editorState.getSelectedNodes(selection);
  final html = documentToHTML(
    Document(
      root: Node(
        type: 'page',
        children: nodes,
      ),
    ),
  );
  AppFlowyClipboard.setData(
    text: text,
    html: html.isEmpty ? null : html,
  );
  return;
}

void _pasteMultipleLinesInText(
  EditorState editorState,
  int offset,
  List<Node> nodes,
) {
  final tb = editorState.transaction;
  final selection = editorState.selection;
  final afterSelection =
      _computeSelectionAfterPasteMultipleNodes(editorState, nodes);

  final selectionNode = editorState.getNodesInSelection(selection!);
  if (selectionNode.length == 1) {
    final node = selectionNode.first;
    final delta = node.delta;
    if (delta == null) {
      tb.afterSelection = afterSelection;
      tb.insertNodes(afterSelection.end.path, nodes);
      editorState.apply(tb);
    }

    final (firstnode, afternode) = sliceNode(node, offset);
    if (nodes.length == 1 && nodes.first.type == node.type) {
      tb.deleteNode(node);
      final List<dynamic> newdelta = firstnode.delta != null
          ? firstnode.delta!.toJson()
          : Delta().toJson();
      final List<Node> childrens = [];
      childrens.addAll(firstnode.children);

      if (nodes.first.delta != null &&
          nodes.first.delta != null &&
          nodes.first.delta!.isNotEmpty) {
        newdelta.addAll(nodes.first.delta!.toJson());
        childrens.addAll(nodes.first.children);
      }
      if (afternode != null &&
          afternode.delta != null &&
          afternode.delta!.isNotEmpty) {
        newdelta.addAll(afternode.delta!.toJson());
        childrens.addAll(afternode.children);
      }

      tb.insertNodes(afterSelection.end.path, [
        Node(
          type: firstnode.type,
          children: childrens,
          attributes: firstnode.attributes
            ..remove(ParagraphBlockKeys.delta)
            ..addAll(
              {ParagraphBlockKeys.delta: Delta.fromJson(newdelta).toJson()},
            ),
        )
      ]);
      editorState.apply(tb);
      return;
    }
    final path = node.path;
    tb.deleteNode(node);
    tb.insertNodes([
      path.first + 1
    ], [
      firstnode,
      ...nodes,
      if (afternode != null &&
          afternode.delta != null &&
          afternode.delta!.isNotEmpty)
        afternode,
    ]);
    editorState.apply(tb);
    return;
  }

  tb.afterSelection = afterSelection;
  tb.insertNodes(afterSelection.end.path, nodes);
  editorState.apply(tb);
}

void handlePaste(EditorState editorState) async {
  final data = await AppFlowyClipboard.getData();

  if (editorState.selection?.isCollapsed ?? false) {
    _pastRichClipboard(editorState, data);
    return;
  }

  deleteSelectedContent(editorState);

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _pastRichClipboard(editorState, data);
  });
}

(Node previousDelta, Node? nextDelta) sliceNode(
  Node node,
  int selectionIndex,
) {
  final delta = node.delta;
  if (delta == null) {
    return (node, null); // // Node doesn't have a delta
  }

  final previousDelta = delta.slice(0, selectionIndex);

  final nextDelta = delta.slice(selectionIndex, delta.length);

  return (
    Node(
      id: node.id,
      parent: node.parent,
      children: node.children,
      type: node.type,
      attributes: node.attributes
        ..remove(ParagraphBlockKeys.delta)
        ..addAll({ParagraphBlockKeys.delta: previousDelta.toJson()}),
    ),
    Node(
      type: node.type,
      attributes: node.attributes
        ..remove(ParagraphBlockKeys.delta)
        ..addAll({ParagraphBlockKeys.delta: nextDelta.toJson()}),
    )
  );
}

void _pastRichClipboard(EditorState editorState, AppFlowyClipboardData data) {
  if (data.html != null) {
    pasteHTML(editorState, data.html!);
    return;
  }
  if (data.text != null) {
    handlePastePlainText(editorState, data.text!);
    return;
  }
}

/// 2. delete selected content
void handleCut(EditorState editorState) {
  handleCopy(editorState);
  deleteSelectedContent(editorState);
}

void deleteSelectedContent(EditorState editorState) async {
  final selection = editorState.selection?.normalized;
  if (selection == null || selection.isCollapsed) {
    return;
  }
  final tb = editorState.transaction;
  await editorState.deleteSelection(selection);
  tb.afterSelection = Selection.collapsed(selection.start);
  editorState.apply(tb);
  return;
}
