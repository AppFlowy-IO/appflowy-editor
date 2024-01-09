import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

enum SelectionRange {
  character,
  word,
}

extension PositionExtension on Position {
  Position? moveHorizontal(
    EditorState editorState, {
    bool forward = true,
    SelectionRange selectionRange = SelectionRange.character,
  }) {
    final node = editorState.document.nodeAtPath(path);
    if (node == null) {
      return null;
    }

    if (forward && offset == 0) {
      final previousEnd = node.previous?.selectable?.end();
      if (previousEnd != null) {
        return previousEnd;
      }
      return null;
    } else if (!forward) {
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
            offset: forward
                ? delta.prevRunePosition(offset)
                : delta.nextRunePosition(offset),
          );
        }

        return Position(path: path, offset: offset);
      case SelectionRange.word:
        final delta = node.delta;
        if (delta != null) {
          final result = forward
              ? node.selectable?.getWordBoundaryInPosition(
                  Position(
                    path: path,
                    offset: delta.prevRunePosition(offset),
                  ),
                )
              : node.selectable?.getWordBoundaryInPosition(this);
          if (result != null) {
            return forward ? result.start : result.end;
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

    final position =
        editorState.service.selectionService.getPositionInOffset(offset);

    if (position != null && !position.path.equals(path)) {
      return position;
    }

    if (upwards) {
      final previous = selection.start.path.previous;
      if (previous.isNotEmpty && !previous.equals(selection.start.path)) {
        final node = editorState.document.nodeAtPath(previous);
        final selectable = node?.selectable;
        var offset = selection.startIndex;
        if (selectable != null) {
          offset = offset.clamp(
            selectable.start().offset,
            selectable.end().offset,
          );
          return Position(path: previous, offset: offset);
        }
      }
    } else {
      final next = selection.end.path.next;
      if (next.isNotEmpty && !next.equals(selection.end.path)) {
        final node = editorState.document.nodeAtPath(next);
        final selectable = node?.selectable;
        var offset = selection.endIndex;
        if (selectable != null) {
          offset = offset.clamp(
            selectable.start().offset,
            selectable.end().offset,
          );
          return Position(path: next, offset: offset);
        }
      }
    }

    return this;
  }
}
