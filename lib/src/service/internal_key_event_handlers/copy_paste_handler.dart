import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/infra/clipboard.dart';
import 'package:appflowy_editor/src/service/internal_key_event_handlers/number_list_helper.dart';
import 'package:flutter/material.dart';

int _textLengthOfNode(Node node) {
  if (node is TextNode) {
    return node.delta.length;
  }

  return 0;
}

Selection _computeSelectionAfterPasteMultipleNodes(
  EditorState editorState,
  List<Node> nodes,
) {
  final currentSelection = editorState.cursorSelection!;
  final currentCursor = currentSelection.start;
  final currentPath = [...currentCursor.path];
  currentPath[currentPath.length - 1] += nodes.length;
  int lenOfLastNode = _textLengthOfNode(nodes.last);
  return Selection.collapsed(
    Position(path: currentPath, offset: lenOfLastNode),
  );
}

void _handleCopy(EditorState editorState) async {
  final selection = editorState.selection?.normalized;
  if (selection == null || selection.isCollapsed) {
    return;
  }
  if (selection.start.path.equals(selection.end.path)) {
    final nodeAtPath = editorState.document.nodeAtPath(selection.end.path)!;

    final textNode = nodeAtPath;
    final htmlString = nodesToHTML([textNode]);
    String textString = "";
    final Delta? delta = textNode.delta;
    final childrens = textNode.children;
    final deltaStrin = delta != null ? delta.toPlainText() : "";
    if (childrens == null) {
      textString = deltaStrin;
    } else {
      final String chilrenString = childrens.fold('', (previousValue, node) {
        final delta = node.delta;
        if (delta != null) {
          return previousValue + '\n' + delta.toPlainText();
        }

        return previousValue;
      });
      textString = "$deltaStrin $chilrenString";
    }
    Log.keyboard.debug('copy html: $htmlString');
    AppFlowyClipboard.setData(
      text: textString,
      html: htmlString,
    );

    return;
  }

  final beginNode = editorState.document.nodeAtPath(selection.start.path)!;
  final endNode = editorState.document.nodeAtPath(selection.end.path)!;

  final nodes = NodeIterator(
    document: editorState.document,
    startNode: beginNode,
    endNode: endNode,
  ).toList();

  final html = nodesToHTML(nodes);
  var text = '';
  for (final node in nodes) {
    String textString = "";
    final Delta? delta = node.delta;
    final childrens = node.children;
    final deltaString = delta != null ? delta.toPlainText() : "";
    if (childrens == null) {
      textString = deltaString;
    } else {
      final String chilrenString =
          childrens.fold('', (previousValue, stringnode) {
        final delta = node.delta;
        if (delta != null) {
          return previousValue + '\n' + delta.toPlainText();
        }

        return previousValue;
      });
      textString = "$deltaString $chilrenString";
    }
    text = text + textString + '\n';
  }
  Log.keyboard.debug('copy html: $html');
  AppFlowyClipboard.setData(
    text: text,
    html: html,
  );
}

void _pasteHTML(EditorState editorState, String html) {
  final selection = editorState.cursorSelection?.normalized;
  if (selection == null) {
    return;
  }

  assert(selection.isCollapsed);

  final path = [...selection.end.path];
  if (path.isEmpty) {
    return;
  }

  Log.keyboard.debug('paste html: $html');
  final htmltoNodes = htmlToNodes(html);

  if (htmltoNodes.isEmpty) {
    return;
  }

  _pasteMultipleLinesInText(
      editorState, path, selection.start.offset, htmltoNodes);
}

void _pasteMultipleLinesInText(
  EditorState editorState,
  List<int> path,
  int offset,
  List<Node> nodes,
) {
  final tb = editorState.transaction;

  final firstNode = nodes[0];
  final nodeAtPath = editorState.document.nodeAtPath(path)!;

  if (nodeAtPath.type == 'text' && firstNode.type == 'text') {
    int? startNumber;
    if (nodeAtPath.subtype == BuiltInAttributeKey.numberList) {
      startNumber = nodeAtPath.attributes[BuiltInAttributeKey.number] as int;
    }

    // split and merge
    final textNodeAtPath = nodeAtPath as TextNode;
    final firstTextNode = firstNode as TextNode;
    final remain = textNodeAtPath.delta.slice(offset);

    tb.updateText(
      textNodeAtPath,
      (Delta()
            ..retain(offset)
            ..delete(remain.length)) +
          firstTextNode.delta,
    );
    tb.updateNode(textNodeAtPath, firstTextNode.attributes);

    final tailNodes = nodes.sublist(1);
    final originalPath = [...path];
    path[path.length - 1]++;

    final afterSelection =
        _computeSelectionAfterPasteMultipleNodes(editorState, tailNodes);

    if (tailNodes.isNotEmpty) {
      if (tailNodes.last.type == "text") {
        final tailTextNode = tailNodes.last as TextNode;
        tailTextNode.delta = tailTextNode.delta + remain;
      } else if (remain.isNotEmpty) {
        tailNodes.add(TextNode(delta: remain));
      }
    } else {
      tailNodes.add(TextNode(delta: remain));
    }

    tb.afterSelection = afterSelection;
    tb.insertNodes(path, tailNodes);
    editorState.apply(tb);

    if (startNumber != null) {
      makeFollowingNodesIncremental(
        editorState,
        originalPath,
        afterSelection,
        beginNum: startNumber,
      );
    }
    return;
  }

  final afterSelection =
      _computeSelectionAfterPasteMultipleNodes(editorState, nodes);

  path[path.length - 1]++;
  tb.afterSelection = afterSelection;
  tb.insertNodes(path, nodes);
  editorState.apply(tb);
}

void _handlePaste(EditorState editorState) async {
  final data = await AppFlowyClipboard.getData();

  if (editorState.cursorSelection?.isCollapsed ?? false) {
    _pastRichClipboard(editorState, data);
    return;
  }

  _deleteSelectedContent(editorState);

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _pastRichClipboard(editorState, data);
  });
}

void _pastRichClipboard(EditorState editorState, AppFlowyClipboardData data) {
  if (data.html != null) {
    _pasteHTML(editorState, data.html!);
    return;
  }
  if (data.text != null) {
    handlePastePlainText(editorState, data.text!);
    return;
  }
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

/// parse url from the line text
/// reference: https://stackoverflow.com/questions/59444837/flutter-dart-regex-to-extract-urls-from-a-string
Delta _lineContentToDelta(String lineContent) {
  final exp = RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\#\w/\-?=%.]+');
  final Iterable<RegExpMatch> matches = exp.allMatches(lineContent);

  final delta = Delta();

  var lastUrlEndOffset = 0;

  for (final match in matches) {
    if (lastUrlEndOffset < match.start) {
      delta.insert(lineContent.substring(lastUrlEndOffset, match.start));
    }
    final linkContent = lineContent.substring(match.start, match.end);
    delta.insert(linkContent, attributes: {"href": linkContent});
    lastUrlEndOffset = match.end;
  }

  if (lastUrlEndOffset < lineContent.length) {
    delta.insert(lineContent.substring(lastUrlEndOffset, lineContent.length));
  }

  return delta;
}

void _pasteMarkdown(EditorState editorState, String markdown) {
  final selection =
      editorState.service.selectionService.currentSelection.value?.normalized;
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
  if (node is TextNode && node.toPlainText().isEmpty) {
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

/// 1. copy the selected content
/// 2. delete selected content
void _handleCut(EditorState editorState) {
  _handleCopy(editorState);
  _deleteSelectedContent(editorState);
}

void _deleteSelectedContent(EditorState editorState) {
  final selection = editorState.cursorSelection?.normalized;
  if (selection == null || selection.isCollapsed) {
    return;
  }
  final beginNode = editorState.document.nodeAtPath(selection.start.path)!;
  final endNode = editorState.document.nodeAtPath(selection.end.path)!;
  if (selection.start.path.equals(selection.end.path) &&
      beginNode.type == "text") {
    final textItem = beginNode as TextNode;
    final tb = editorState.transaction;
    final len = selection.end.offset - selection.start.offset;
    tb.updateText(
      textItem,
      Delta()
        ..retain(selection.start.offset)
        ..delete(len),
    );
    tb.afterSelection = Selection.collapsed(selection.start);
    editorState.apply(tb);
    return;
  }
  final traverser = NodeIterator(
    document: editorState.document,
    startNode: beginNode,
    endNode: endNode,
  );
  final tb = editorState.transaction;
  while (traverser.moveNext()) {
    final item = traverser.current;
    if (item.type == "text" && beginNode == item) {
      final textItem = item as TextNode;
      final deleteLen = textItem.delta.length - selection.start.offset;
      tb.updateText(textItem, () {
        final delta = Delta()
          ..retain(selection.start.offset)
          ..delete(deleteLen);

        if (endNode is TextNode) {
          final remain = endNode.delta.slice(selection.end.offset);
          delta.addAll(remain);
        }

        return delta;
      }());
    } else {
      tb.deleteNode(item);
    }
  }
  tb.afterSelection = Selection.collapsed(selection.start);
  editorState.apply(tb);
}

ShortcutEventHandler copyEventHandler = (editorState, event) {
  _handleCopy(editorState);
  return KeyEventResult.handled;
};

ShortcutEventHandler pasteEventHandler = (editorState, event) {
  _handlePaste(editorState);
  return KeyEventResult.handled;
};

ShortcutEventHandler cutEventHandler = (editorState, event) {
  _handleCut(editorState);
  return KeyEventResult.handled;
};
