import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:appflowy_editor/appflowy_editor.dart';

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
    final node = editorState.document.nodeAtPath(path);
    final nodeRenderBox = node?.renderBox;
    final nodeSelectable = node?.selectable;
    if (node == null || nodeRenderBox == null || nodeSelectable == null) {
      return this;
    }

    final editorSelection = editorState.selection;
    final rects = editorState.selectionRects();
    if (rects.isEmpty || editorSelection == null) {
      return null;
    }

    final Rect caretRect = rects.reduce((current, next) {
      if (editorSelection.isBackward) {
        return current.bottom > next.bottom ? current : next;
      }
      return current.top <= next.top ? current : next;
    });

    // The offset of outermost part of the caret.
    // Either the top if moving upwards, or the bottom if moving downwards.
    final Offset caretOffset = editorSelection.isBackward
        ? upwards
            ? caretRect.topRight
            : caretRect.bottomRight
        : upwards
            ? caretRect.topLeft
            : caretRect.bottomLeft;

    final nodeConfig = editorState.service.rendererService
        .blockComponentBuilder(node.type)
        ?.configuration;
    if (nodeConfig == null) {
      assert(nodeConfig != null, 'Block Configuration should not be null');
      return this;
    }

    final padding = nodeConfig.padding(node);
    final nodeRect = nodeSelectable.getBlockRect();
    final nodeHeight = nodeRect.height;
    final textHeight = nodeHeight - padding.vertical;
    final caretHeight = caretRect.height;

    // Minimum (acceptable) font size
    // Consider augmenting this value to increase performance.
    const double minFontSize = 1.0;

    // If the current node is not multiline, this will be ~= 0
    // so the loop will be skipped.
    final remainingMultilineHeight = (textHeight - caretHeight);

    // Linearly search for a new position.
    // It's acceptable to use a linear search because the starting point is
    // the most outer part of the caret, so:
    // - If the current node is multine:
    //   - If the caret is NOT in the first/last line: at the first iteration
    //      the cycle a new position (of the previous/next multiline's line)
    //      will be found, practically ignoring the complexity of the cycle.
    //   - If the caret is in the first/last line: this is the worst case
    //      scenario, but only if the padding choosen by the user is very
    //      large. (padding >= (multiline's textHeight - caretHeight) / 3
    //      can start to be considered large. Note that in an average bad case
    //      scenario the position will be found in 10/12 ms instead of 1/2 ms)
    // - If the current node is not multiline: the cycle will be completely
    //   skipped because `remainingMultilineHeight` would be 0.
    Offset newOffset = caretOffset;
    Position? newPosition;
    for (double y = minFontSize;
        y < remainingMultilineHeight + minFontSize;
        y += minFontSize) {
      newOffset = caretOffset.translate(0, upwards ? -y : y);

      newPosition =
          editorState.service.selectionService.getPositionInOffset(newOffset);

      // If a position different from the current one is found, return it.
      if (newPosition != null && newPosition != this) {
        return newPosition;
      }
    }

    // If a new position has not been found, it means that the current node
    // is not multiline (or the caret is in the last line of a multiline and
    // the bottom padding is very large).
    // In this case, we can manually skip to the previous/next node position
    // by translating the new offset by the padding slice to skip.
    // Note that the padding slice to skip can exceed the node's bounds.
    final maxSkip = upwards ? padding.top : padding.bottom;

    // Translate the new offset by the padding slice to skip.
    newOffset = newOffset.translate(0, upwards ? -maxSkip : maxSkip);

    // Determine node's global position.
    final nodeHeightOffset = nodeRenderBox.localToGlobal(Offset(0, nodeHeight));

    // Clamp the new offset to the node's bounds.
    newOffset = Offset(
      newOffset.dx,
      math.min(newOffset.dy, nodeHeightOffset.dy),
    );

    newPosition =
        editorState.service.selectionService.getPositionInOffset(newOffset);

    if (newPosition != null && newPosition != this) {
      return newPosition;
    }

    // If a new position has not been found, it means that the current node
    // is not visible on the screen. It seems happens only if upwards is true (?)
    // In this case, we can manually get the previous/next node position.
    int offset = editorSelection.end.offset;
    final List<int> nodePath = editorSelection.end.path;
    final List<int> neighbourPath = upwards ? nodePath.previous : nodePath.next;
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
