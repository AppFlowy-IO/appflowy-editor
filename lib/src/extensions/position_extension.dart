import 'dart:math' as math;

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
    //* GET THE CURRENT OFFSET
    final selection = editorState.selection;
    final rects = editorState.selectionRects();
    if (rects.isEmpty || selection == null) {
      return null;
    }

    Offset currentOffset;
    final Rect caretRect;
    if (selection.isBackward) {
      caretRect = rects.reduce(
        (current, next) => current.bottom > next.bottom ? current : next,
      );
      currentOffset =
          upwards ? throw Exception('Ivalid state') : caretRect.bottomRight;
    } else {
      caretRect = rects.reduce(
        (current, next) => current.top <= next.top ? current : next,
      );
      currentOffset = upwards ? caretRect.topLeft : caretRect.bottomLeft;
    }

    //* GET THE CURRENT NODE'S TEXT HEIGHT
    final node = editorState.document.nodeAtPath(path);
    if (node == null) {
      return this;
    }

    final nodeRenderBox = node.renderBox;
    if (nodeRenderBox == null) {
      return this;
    }

    final selectable = node.selectable;
    if (selectable == null) {
      return this;
    }

    final paddingCalculator = editorState.service.rendererService
        .blockComponentBuilder(node.type)
        ?.configuration
        .padding;

    if (paddingCalculator == null) {
      // This should not happen.
      return this;
    }

    final padding = paddingCalculator(node);
    final verticalPadding = padding.vertical;

    final rect = selectable.getBlockRect();
    final nodeHeight = rect.height;
    final textHeight = nodeHeight - verticalPadding;
    final caretHeight = caretRect.height;
    final maxYToSkip = upwards ? padding.top : padding.bottom;

    // If the current node is not multiline, this will be ~= 0
    // so the step 1 will be skipped.
    final remainingMultilineHeight = (textHeight - caretHeight);

    //* GET THE CLOSEST POSITION TO THE CURRENT OFFSET
    //* Step 1: Loop through the current node's text height until the text
    //* height is reached or a new position is found.
    Offset newOffset = currentOffset;
    Position? newPosition;
    double minFontSize =
        1; // Consider augmenting this value to increase performance.
    double y = minFontSize;
    for (; y < remainingMultilineHeight + minFontSize; y += minFontSize) {
      newOffset = currentOffset.translate(0, upwards ? -y : y);

      newPosition =
          editorState.service.selectionService.getPositionInOffset(newOffset);

      if (newPosition != null && newPosition != this) {
        return newPosition;
      }
    }

    //* Step 2: If arrived here it surely hasn't found a different vertical position in the same node (not multiline or last line of a multiline).
    //* So we can skip to `maxYToSkip` steps to surely move to a new node.
    // We have to decrease 'y' by 'minFontSize' because the last iteration has increased it by 'minFontSize'.
    y -= minFontSize;

    // Increase y by the padding slice to skip.
    y += maxYToSkip;
    newOffset = currentOffset.translate(0, upwards ? -y : y);

    // Determine node's global position.
    final nodeYOffsetTop = nodeRenderBox.localToGlobal(Offset.zero).dy;
    final nodeYOffsetBottom = nodeYOffsetTop + nodeHeight;

    newOffset = Offset(newOffset.dx, math.min(newOffset.dy, nodeYOffsetBottom));

    newPosition =
        editorState.service.selectionService.getPositionInOffset(newOffset);

    if (newPosition != null && newPosition != this) {
      return newPosition;
    }

    //* Step 3: If arrived here the previous/next node is not visibile on the screen
    //* so we have to manually move to the previous/next node's position.
    final List<int> neighbourPath;
    final List<int> nodePath;
    int offset;
    if (upwards) {
      neighbourPath = selection.start.path.previous;
      nodePath = selection.start.path;
      offset = selection.startIndex;
    } else {
      neighbourPath = selection.end.path.next;
      nodePath = selection.end.path;
      offset = selection.endIndex;
    }

    if (neighbourPath.isNotEmpty && !neighbourPath.equals(nodePath)) {
      final neighbour = editorState.document.nodeAtPath(neighbourPath);
      final selectable = neighbour?.selectable;
      if (selectable != null) {
        offset = offset.clamp(
          selectable.start().offset,
          selectable.end().offset,
        );
        return Position(path: neighbourPath, offset: offset);
      }
    }

    // The cursor is already at the top or bottom of the document.
    return this;
  }
}
