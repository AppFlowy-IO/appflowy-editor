import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/widgets.dart';

int _textLengthOfNode(Node node) => node.delta?.length ?? 0;
RegExp _linkRegex = RegExp(
  r'https?://(?:www\.)?[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}(?:/[^\s]*)?',
);

void _pasteSingleLine(
  EditorState editorState,
  Selection selection,
  String line,
) {
  assert(selection.isCollapsed);

  // handle link
  final Attributes attributes = _linkRegex.hasMatch(line)
      ? {
          AppFlowyRichTextKeys.href: line,
        }
      : {};

  final node = editorState.getNodeAtPath(selection.end.path)!;
  final transaction = editorState.transaction
    ..insertText(node, selection.startIndex, line, attributes: attributes)
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
    ..afterSelection =
        Selection.collapsed(Position(path: afterPath, offset: offset));
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
  if (selection == null || !selection.isCollapsed) {
    return;
  }

  Log.keyboard.debug('paste html: $html');

  final htmlToNodes = htmlToDocument(html).root.children.where((element) {
    final delta = element.delta;
    if (delta == null) {
      return true;
    }
    return delta.isNotEmpty;
  });
  if (htmlToNodes.isEmpty) {
    return;
  }

  if (htmlToNodes.length == 1) {
    _pasteSingleLineInText(
      editorState,
      selection.startIndex,
      htmlToNodes.first,
    );
  } else {
    _pasteMultipleLinesInText(
      editorState,
      selection.start.offset,
      htmlToNodes.toList(),
    );
  }
}

Selection _computeSelectionAfterPasteMultipleNodes(
  EditorState editorState,
  List<Node> nodes,
) {
  final currentSelection = editorState.selection!;
  final currentCursor = currentSelection.start;
  final currentPath = [...currentCursor.path];
  currentPath[currentPath.length - 1] += nodes.length;
  final int lenOfLastNode = _textLengthOfNode(nodes.last);
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
  final nodes = editorState.getSelectedNodes(selection: selection);
  if (nodes.isEmpty) {
    return;
  }
  final html = documentToHTML(
    Document(
      root: Node(
        type: 'page',
        children: nodes,
      ),
    ),
  );
  return AppFlowyClipboard.setData(
    text: text,
    html: html.isEmpty ? null : html,
  );
}

void _pasteSingleLineInText(
  EditorState editorState,
  int offset,
  Node insertedNode,
) {
  final transaction = editorState.transaction;
  final selection = editorState.selection;
  if (selection == null || !selection.isCollapsed) {
    return;
  }
  final node = editorState.getNodeAtPath(selection.end.path);
  final delta = node?.delta;
  if (node == null || delta == null) {
    return;
  }
  final insertedDelta = insertedNode.delta;
  if (delta.isEmpty || insertedDelta == null) {
    transaction.insertNode(selection.end.path.next, insertedNode);
    transaction.deleteNode(node);
    final length = insertedNode.delta?.length ?? 0;
    transaction.afterSelection =
        Selection.collapsed(Position(path: selection.end.path, offset: length));
    editorState.apply(transaction);
  } else {
    transaction.insertTextDelta(
      node,
      offset,
      insertedDelta,
    );
    editorState.apply(transaction);
  }
}

void _pasteMultipleLinesInText(
  EditorState editorState,
  int offset,
  List<Node> nodes,
) {
  final transaction = editorState.transaction;
  final selection = editorState.selection;
  final afterSelection =
      _computeSelectionAfterPasteMultipleNodes(editorState, nodes);

  final selectionNode = editorState.getNodesInSelection(selection!);
  if (selectionNode.length == 1) {
    final node = selectionNode.first;
    if (node.delta == null) {
      transaction.afterSelection = afterSelection;
      transaction.insertNodes(afterSelection.end.path, nodes);
      editorState.apply(transaction);
    }

    final (firstNode, afterNode) = sliceNode(node, offset);
    if (nodes.length == 1 && nodes.first.type == node.type) {
      transaction.deleteNode(node);
      final List<dynamic> newDelta = firstNode.delta != null
          ? firstNode.delta!.toJson()
          : Delta().toJson();
      final List<Node> children = [];
      children.addAll(firstNode.children);

      if (nodes.first.delta != null &&
          nodes.first.delta != null &&
          nodes.first.delta!.isNotEmpty) {
        newDelta.addAll(nodes.first.delta!.toJson());
        children.addAll(nodes.first.children);
      }
      if (afterNode != null &&
          afterNode.delta != null &&
          afterNode.delta!.isNotEmpty) {
        newDelta.addAll(afterNode.delta!.toJson());
        children.addAll(afterNode.children);
      }

      transaction.insertNodes(afterSelection.end.path, [
        Node(
          type: firstNode.type,
          children: children,
          attributes: firstNode.attributes
            ..remove(ParagraphBlockKeys.delta)
            ..addAll(
              {ParagraphBlockKeys.delta: Delta.fromJson(newDelta).toJson()},
            ),
        ),
      ]);
      transaction.afterSelection = afterSelection;
      editorState.apply(transaction);
      return;
    }
    final path = node.path;
    transaction.deleteNode(node);
    transaction.insertNodes([
      path.first + 1,
    ], [
      firstNode,
      ...nodes,
      if (afterNode != null &&
          afterNode.delta != null &&
          afterNode.delta!.isNotEmpty)
        afterNode,
    ]);
    transaction.afterSelection = afterSelection;
    editorState.apply(transaction);
    return;
  }

  transaction.afterSelection = afterSelection;
  transaction.insertNodes(afterSelection.end.path, nodes);
  editorState.apply(transaction);
}

void handlePaste(EditorState editorState) async {
  final data = await AppFlowyClipboard.getData();

  if (editorState.selection?.isCollapsed ?? false) {
    return _pasteRichClipboard(editorState, data);
  }

  deleteSelectedContent(editorState);

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _pasteRichClipboard(editorState, data);
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

void _pasteRichClipboard(EditorState editorState, AppFlowyClipboardData data) {
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
}
