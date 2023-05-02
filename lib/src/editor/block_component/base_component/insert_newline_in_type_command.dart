import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

Future<bool> insertNewLineInType(
  EditorState editorState,
  String type, {
  Attributes attributes = const {},
}) async {
  final selection = editorState.selection;
  if (selection == null || !selection.isCollapsed) {
    return false;
  }

  final node = editorState.getNodeAtPath(selection.end.path);
  final delta = node?.delta;
  if (node?.type != type || delta == null) {
    return false;
  }

  if (selection.startIndex == 0 && delta.isEmpty) {
    // clear the style

    return KeyEventResult.ignored !=
        convertToParagraphCommand.execute(editorState);
  }

  await editorState.insertNewLine(
    nodeBuilder: (node) => node.copyWith(
      type: type,
      attributes: {
        ...node.attributes,
        ...attributes,
      },
    ),
  );
  return true;
}
