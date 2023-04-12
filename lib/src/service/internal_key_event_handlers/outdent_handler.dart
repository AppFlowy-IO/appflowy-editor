import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

ShortcutEventHandler outdentTabHandler = (editorState, event) {
  final selection = editorState.service.selectionService.currentSelection.value;
  final textNodes = editorState.service.selectionService.currentSelectedNodes
      .whereType<TextNode>();
  if (textNodes.length != 1 || selection == null || !selection.isSingle) {
    return KeyEventResult.ignored;
  }

  final textNode = textNodes.first;
  var previous = textNode.previous;

  if (![BuiltInAttributeKey.bulletedList, BuiltInAttributeKey.checkbox]
      .contains(textNode.subtype)) {
    return KeyEventResult.handled;
  }

  //if the current node is having a path which is of size 1.
  //for example [0], then that means, it is not indented
  //thus we ignore this event.
  final oldPath = textNode.path;
  if (oldPath.length == 1) {
    return KeyEventResult.handled;
  }

  //we need to check if the previous node is a list type or not,
  //but the previous getter gives the previous node in the LinkedList
  //in case of nested bullet lists, where an element's path is [1,0]
  //the previous getter will return null, but in this case: we should
  //assign previous's path to be = [1]
  if (previous == null) {
    if (oldPath.last != 0) {
      return KeyEventResult.ignored;
    }

    final previousPath = oldPath.sublist(0, oldPath.length - 1);
    editorState.updateCursorSelection(
        Selection.single(path: previousPath, startOffset: 0));

    final prevSelection =
        editorState.service.selectionService.currentSelection.value;

    final prevNodes = editorState.service.selectionService.currentSelectedNodes
        .whereType<TextNode>();

    if (prevNodes.length != 1 ||
        prevSelection == null ||
        !prevSelection.isSingle) {
      return KeyEventResult.ignored;
    }

    previous = prevNodes.first;
  }

  if (![BuiltInAttributeKey.bulletedList, BuiltInAttributeKey.checkbox]
      .contains(previous.subtype)) {
    return KeyEventResult.ignored;
  }

  final path = oldPath.sublist(0, oldPath.length - 1);
  path[path.length - 1] += 1;

  final afterSelection = Selection(
    start: selection.start.copyWith(path: path),
    end: selection.end.copyWith(path: path),
  );
  final transaction = editorState.transaction
    ..deleteNode(textNode)
    ..insertNode(path, textNode)
    ..afterSelection = afterSelection;
  editorState.apply(transaction);

  return KeyEventResult.handled;
};
