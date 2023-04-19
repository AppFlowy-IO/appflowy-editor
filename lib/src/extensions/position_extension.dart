import 'package:appflowy_editor/appflowy_editor.dart';

enum SelectionRange {
  character,
  word,
}

extension PositionExtension on Position {
  Position? goLeft(
    EditorState editorState, {
    SelectionRange selectionRange = SelectionRange.character,
  }) {
    final node = editorState.document.nodeAtPath(path);
    if (node == null) {
      return null;
    }

    if (offset == 0) {
      final previousEnd = node.previous?.selectable?.end();
      if (previousEnd != null) {
        return previousEnd;
      }
      return null;
    }

    switch (selectionRange) {
      case SelectionRange.character:
        if (node is TextNode) {
          return Position(
            path: path,
            offset: node.delta.prevRunePosition(offset),
          );
        }

        return Position(path: path, offset: offset);
      case SelectionRange.word:
        if (node is TextNode) {
          final result = node.selectable?.getWordBoundaryInPosition(
            Position(
              path: path,
              offset: node.delta.prevRunePosition(offset),
            ),
          );
          if (result != null) {
            return result.start;
          }
        }

        return Position(path: path, offset: offset);
    }
  }

  Position? goRight(
    EditorState editorState, {
    SelectionRange selectionRange = SelectionRange.character,
  }) {
    final node = editorState.document.nodeAtPath(path);
    if (node == null) {
      return null;
    }

    final end = node.selectable?.end();
    if (end != null && offset >= end.offset) {
      return node.next?.selectable?.start();
    }

    switch (selectionRange) {
      case SelectionRange.character:
        if (node is TextNode) {
          return Position(
            path: path,
            offset: node.delta.nextRunePosition(offset),
          );
        }

        return Position(path: path, offset: offset);
      case SelectionRange.word:
        if (node is TextNode) {
          final result = node.selectable?.getWordBoundaryInPosition(this);
          if (result != null) {
            return result.end;
          }
        }

        return Position(path: path, offset: offset);
    }
  }
}
