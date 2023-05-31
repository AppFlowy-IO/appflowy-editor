import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

enum SelectionRange {
  character,
  word,
}

extension PositionExtension on Position {
  Position? moveHorizontal(
    EditorState editorState, {
    bool moveLeft = true,
    SelectionRange selectionRange = SelectionRange.character,
  }) {
    final node = editorState.document.nodeAtPath(path);
    if (node == null) {
      return null;
    }

    if (moveLeft && offset == 0) {
      final previousEnd = node.previous?.selectable?.end();
      if (previousEnd != null) {
        return previousEnd;
      }
      return null;
    } else if (!moveLeft) {
      final end = node.selectable?.end();
      if (end != null && offset >= end.offset) {
        return node.next?.selectable?.start();
      }
    }

    switch (selectionRange) {
      case SelectionRange.character:
        final delta = node.delta;
        if (delta != null) {
          return Position(
            path: path,
            offset: moveLeft
                ? delta.prevRunePosition(offset)
                : delta.nextRunePosition(offset),
          );
        }

        return Position(path: path, offset: offset);
      case SelectionRange.word:
        final delta = node.delta;
        if (delta != null) {
          final result = moveLeft
              ? node.selectable?.getWordBoundaryInPosition(
                  Position(
                    path: path,
                    offset: delta.prevRunePosition(offset),
                  ),
                )
              : node.selectable?.getWordBoundaryInPosition(this);
          if (result != null) {
            return moveLeft ? result.start : result.end;
          }
        }

        return Position(path: path, offset: offset);
    }
  }

  Position? moveVertical(
    EditorState editorState, {
    bool upwards = true,
  }) {
    final selection = editorState.selection;
    final rects = editorState.selectionRects();
    if (rects.isEmpty || selection == null) {
      return null;
    }

    Offset offset;
    if (selection.isBackward) {
      final rect = rects.reduce(
        (current, next) => current.bottom >= next.bottom ? current : next,
      );
      offset = upwards
          ? rect.topRight.translate(0, -rect.height)
          : rect.centerRight.translate(0, rect.height);
    } else {
      final rect = rects.reduce(
        (current, next) => current.top <= next.top ? current : next,
      );
      offset = upwards
          ? rect.topLeft.translate(0, -rect.height)
          : rect.centerLeft.translate(0, rect.height);
    }

    return editorState.service.selectionService.getPositionInOffset(offset);
  }
}
