import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

abstract class AutoScrollerService {
  void startAutoScroll(
    Offset offset, {
    double edgeOffset = 200,
    AxisDirection? direction,
  });
  void stopAutoScroll();
  void scrollOnUpdate(
    EditorState editorState, {
    Rect? cursorRect,
    BuildContext? context,
    List<Node>? currentSelectedNodes,
    Selection? currentSelection,
  });
}

class AutoScroller extends EdgeDraggingAutoScroller
    implements AutoScrollerService {
  AutoScroller(
    super.scrollable, {
    super.onScrollViewScrolled,
    super.velocityScalar = _kDefaultAutoScrollVelocityScalar,
  });

  static const double _kDefaultAutoScrollVelocityScalar = 7;

  @override
  void startAutoScroll(
    Offset offset, {
    double edgeOffset = 200,
    AxisDirection? direction,
  }) {
    if (direction != null) {
      if (direction == AxisDirection.up) {
        startAutoScrollIfNecessary(
          offset & Size(1, edgeOffset),
        );
      }
    } else {
      startAutoScrollIfNecessary(
        offset.translate(0, -edgeOffset) & Size(1, 2 * edgeOffset),
      );
    }
  }

  RevealedOffset _getOffsetToRevealCaret(
    Rect rect, {
    required EditorState editorState,
  }) {
    if (!editorState.service.scrollService!.implicit) {
      return RevealedOffset(
        offset: editorState.service.scrollService!.offset,
        rect: rect,
      );
    }

    final Size editableSize = editorState.renderBox!.size;
    final double additionalOffset;
    final Offset unitOffset;

    // The caret is vertically centered within the line. Expand the caret's
    // height so that it spans the line because we're going to ensure that the
    // entire expanded caret is scrolled into view.
    final Rect expandedRect = Rect.fromCenter(
      center: rect.center,
      width: rect.width,
      height: math.max(rect.height, 20),
    );

    additionalOffset = expandedRect.height >= editableSize.height
        ? editableSize.height / 2 - expandedRect.center.dy
        : clampDouble(
            0.0,
            expandedRect.bottom - editableSize.height,
            expandedRect.top,
          );
    unitOffset = const Offset(0, 1);

    // No overscrolling when encountering tall fonts/scripts that extend past
    // the ascent.
    final double targetOffset = clampDouble(
      additionalOffset + rect.top + 200,
      editorState.service.scrollService!.minScrollExtent,
      editorState.service.scrollService!.maxScrollExtent,
    );

    return RevealedOffset(
      rect: rect.shift(unitOffset * targetOffset),
      offset: targetOffset,
    );
  }

  @override
  void scrollOnUpdate(
    EditorState editorState, {
    Rect? cursorRect,
    BuildContext? context,
    List<Node>? currentSelectedNodes,
    Selection? currentSelection,
  }) {
    if (Platform.isAndroid || Platform.isIOS) {
      if (cursorRect == null) {
        return;
      }
      final caretOffset =
          _getOffsetToRevealCaret(cursorRect, editorState: editorState).offset;
      editorState.service.scrollService?.scrollController.animateTo(
        caretOffset,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeIn,
      );
    } else {
      if (context == null ||
          currentSelectedNodes == null ||
          currentSelection == null) {
        return;
      }

      _scrollUpOrDownIfNeeded(
        editorState,
        currentSelectedNodes: currentSelectedNodes,
        currentSelection: currentSelection,
        context: context,
      );
    }
  }

  void _scrollUpOrDownIfNeeded(
    EditorState editorState, {
    BuildContext? context,
    required List<Node> currentSelectedNodes,
    Selection? currentSelection,
  }) {
    final dy = editorState.service.scrollService?.dy;

    if (dy == null ||
        currentSelection == null ||
        currentSelectedNodes.isEmpty) {
      return;
    }

    final rect = currentSelectedNodes.last.rect;

    final size = MediaQuery.of(context!).size.height;
    final topLimit = size * 0.3;
    final bottomLimit = size * 0.8;

    // TODO: It is necessary to calculate the relative speed
    //   according to the gap and move forward more gently.
    if (rect.top >= bottomLimit) {
      if (currentSelection.isSingle) {
        editorState.service.scrollService?.scrollTo(dy + size * 0.2);
      } else if (currentSelection.isBackward) {
        editorState.service.scrollService?.scrollTo(dy + 10.0);
      }
    } else if (rect.bottom <= topLimit && currentSelection.isForward) {
      editorState.service.scrollService?.scrollTo(dy - 10.0);
    }
  }
}
