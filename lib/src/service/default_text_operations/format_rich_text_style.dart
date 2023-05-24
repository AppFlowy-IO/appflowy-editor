import 'package:appflowy_editor/appflowy_editor.dart';

void insertHeadingAfterSelection(EditorState editorState, int level) {
  insertNodeAfterSelection(
    editorState,
    headingNode(level: level),
  );
}

void insertQuoteAfterSelection(EditorState editorState) {
  insertNodeAfterSelection(
    editorState,
    quoteNode(),
  );
}

void insertCheckboxAfterSelection(EditorState editorState) {
  insertNodeAfterSelection(
    editorState,
    todoListNode(checked: false),
  );
}

void insertBulletedListAfterSelection(EditorState editorState) {
  insertNodeAfterSelection(
    editorState,
    bulletedListNode(),
  );
}

void insertNumberedListAfterSelection(EditorState editorState) {
  insertNodeAfterSelection(
    editorState,
    numberedListNode(),
  );
}

bool insertNodeAfterSelection(
  EditorState editorState,
  Node node,
) {
  final selection = editorState.selection;
  if (selection == null || !selection.isCollapsed) {
    return false;
  }

  final currentNode = editorState.getNodeAtPath(selection.end.path);
  if (currentNode == null) {
    return false;
  }
  final transaction = editorState.transaction;
  final delta = currentNode.delta;
  if (delta != null && delta.isEmpty) {
    transaction
      ..insertNode(selection.end.path, node)
      ..deleteNode(currentNode);
  } else {
    final next = selection.end.path.next;
    transaction
      ..insertNode(next, node)
      ..afterSelection = Selection.collapsed(
        Position(path: next, offset: 0),
      );
  }

  editorState.apply(transaction);
  return true;
}

void formatText(EditorState editorState) {
  throw UnimplementedError();
}

void formatHeading(EditorState editorState, String heading) {
  throw UnimplementedError();
}

void formatQuote(EditorState editorState) {
  throw UnimplementedError();
}

void formatCheckbox(EditorState editorState, bool check) {
  throw UnimplementedError();
}

void formatBulletedList(EditorState editorState) {
  throw UnimplementedError();
}

bool formatBold(EditorState editorState) {
  return formatRichTextPartialStyle(editorState, BuiltInAttributeKey.bold);
}

bool formatItalic(EditorState editorState) {
  return formatRichTextPartialStyle(editorState, BuiltInAttributeKey.italic);
}

bool formatUnderline(EditorState editorState) {
  return formatRichTextPartialStyle(editorState, BuiltInAttributeKey.underline);
}

bool formatStrikethrough(EditorState editorState) {
  return formatRichTextPartialStyle(
    editorState,
    BuiltInAttributeKey.strikethrough,
  );
}

bool formatEmbedCode(EditorState editorState) {
  return formatRichTextPartialStyle(editorState, BuiltInAttributeKey.code);
}

bool formatHighlight(EditorState editorState, String colorHex) {
  bool value = _allSatisfyInSelection(
    editorState,
    BuiltInAttributeKey.highlightColor,
    colorHex,
  );
  return formatRichTextPartialStyle(
    editorState,
    BuiltInAttributeKey.highlightColor,
    customValue: value ? '0x00000000' : colorHex,
  );
}

bool formatHighlightColor(EditorState editorState, String colorHex) {
  return formatRichTextPartialStyle(
    editorState,
    BuiltInAttributeKey.highlightColor,
    customValue: colorHex,
  );
}

bool formatFontColor(EditorState editorState, String colorHex) {
  return formatRichTextPartialStyle(
    editorState,
    BuiltInAttributeKey.textColor,
    customValue: colorHex,
  );
}

bool formatRichTextPartialStyle(
  EditorState editorState,
  String styleKey, {
  Object? customValue,
}) {
  Attributes attributes = {
    styleKey: customValue ??
        !_allSatisfyInSelection(
          editorState,
          styleKey,
          customValue ?? true,
        ),
  };

  return formatRichTextStyle(editorState, attributes);
}

bool _allSatisfyInSelection(
  EditorState editorState,
  String styleKey,
  dynamic matchValue,
) {
  final selection = editorState.service.selectionService.currentSelection.value;
  final nodes = editorState.service.selectionService.currentSelectedNodes;
  final textNodes = nodes.whereType<TextNode>().toList(growable: false);

  if (selection == null || textNodes.isEmpty) {
    return false;
  }

  return textNodes.allSatisfyInSelection(selection, styleKey, (value) {
    return value == matchValue;
  });
}

bool formatRichTextStyle(EditorState editorState, Attributes attributes) {
  var selection = editorState.service.selectionService.currentSelection.value;
  var nodes = editorState.service.selectionService.currentSelectedNodes;

  if (selection == null) {
    return false;
  }

  nodes = selection.isBackward ? nodes : nodes.reversed.toList(growable: false);
  selection = selection.isBackward ? selection : selection.reversed;

  var textNodes = nodes.whereType<TextNode>().toList();
  if (textNodes.isEmpty) {
    return false;
  }

  final transaction = editorState.transaction;

  // 1. All nodes are text nodes.
  // 2. The first node is not TextNode.
  // 3. The last node is not TextNode.
  if (nodes.length == textNodes.length && textNodes.length == 1) {
    transaction.formatText(
      textNodes.first,
      selection.start.offset,
      selection.end.offset - selection.start.offset,
      attributes,
    );
  } else {
    for (var i = 0; i < textNodes.length; i++) {
      final textNode = textNodes[i];
      var index = 0;
      var length = textNode.toPlainText().length;
      if (i == 0 && textNode == nodes.first) {
        index = selection.start.offset;
        length = textNode.toPlainText().length - selection.start.offset;
      } else if (i == textNodes.length - 1 && textNode == nodes.last) {
        length = selection.end.offset;
      }
      transaction.formatText(
        textNode,
        index,
        length,
        attributes,
      );
    }
  }

  editorState.apply(transaction);

  return true;
}
