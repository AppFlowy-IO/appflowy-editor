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
            offset: forward ? delta.prevRunePosition(offset) : delta.nextRunePosition(offset),
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

  Offset? offsetGet(
    bool selectionIsBackward,
    List<Rect> rects, {
    bool upwards = true,
  }) {
    Offset? offset2;
    if (selectionIsBackward) {
      final rect = rects.reduce(
        (current, next) => current.bottom >= next.bottom ? current : next,
      );
      offset2 = upwards
          ? rect.topRight.translate(0, -rect.height)
          : rect.centerRight.translate(0, rect.height);
    } else {
      final rect = rects.reduce(
        (current, next) => current.top <= next.bottom ? current : next,
      );
      offset2 = upwards
          ? rect.topLeft.translate(0, -rect.height)
          : rect.centerLeft.translate(0, rect.height);
    }
    return offset2;
  }

  Position? getPosition(
    Offset offset,
    AppFlowySelectionService editorStateSelectionService, {
    bool checkedParagraphStep = false,
  }) {
    final position = editorStateSelectionService.getPositionInOffset(offset);
    if (position != null) {
      final nextParagrapStep = checkedParagraphStep ? position.path.equals(path) : false;
      if (!nextParagrapStep) {
        return position;
      }
    }
    return null;
  }

  Position? upWordsPosition({
    required Selection selection,
    required EditorState editorState,
    bool upwards = true,
  }) {
    if (upwards) {
      final previous = selection.start.path.previous;
      if (previous.isNotEmpty && !previous.equals(selection.start.path)) {
        final node = editorState.document.nodeAtPath(previous);
        final selectable = node?.selectable;
        var offsetL = selection.startIndex;
        if (selectable != null) {
          offsetL = offset.clamp(
            selectable.start().offset,
            selectable.end().offset,
          );
          return Position(path: previous, offset: offsetL);
        }
      }
    } else {
      final next = selection.end.path.next;
      if (next.isNotEmpty && !next.equals(selection.end.path)) {
        final node = editorState.document.nodeAtPath(next);
        final selectable = node?.selectable;
        var offsetL = selection.endIndex;
        if (selectable != null) {
          offsetL = offsetL.clamp(
            selectable.start().offset,
            selectable.end().offset,
          );
          return Position(path: next, offset: offsetL);
        }
      }
    }
    return null;
  }

  Position? moveVertical(
    EditorState editorState, {
    bool upwards = true,
    bool checkedParagraphStep = false,
  }) {
    final selection = editorState.selection;
    final rects = editorState.selectionRects();
    if (rects.isEmpty || selection == null) {
      return null;
    }

    Offset? offsetSelectable = offsetGet(selection.isBackward, rects, upwards: upwards);
    if (offsetSelectable != null) {
      final positionSelectable = getPosition(
        offsetSelectable,
        editorState.service.selectionService,
        checkedParagraphStep: checkedParagraphStep,
      );
      if (positionSelectable != null) {
        return positionSelectable;
      }
    }

    final positionUpWords = upWordsPosition(selection: selection, editorState: editorState);
    if (positionUpWords != null) {
      return positionUpWords;
    }

    return this;
  }
}
