import 'dart:math' as math;

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

extension EditorStateSelection on EditorState {
  List<Node> getVisibleNodes(EditorScrollController controller) {
    final List<Node> sortedNodes = [];
    final positions = controller.visibleRangeNotifier.value;
    // https://github.com/AppFlowy-IO/AppFlowy/issues/3651
    final min = math.max(positions.$1 - 1, 0);
    final max = positions.$2;
    if (min < 0 || max < 0) {
      return sortedNodes;
    }

    int i = -1;
    for (final child in document.root.children) {
      i++;
      if (min > i) {
        continue;
      }
      if (i > max) {
        break;
      }
      sortedNodes.add(child);
    }
    return sortedNodes;
  }

  Node? getNodeInOffset(
    List<Node> sortedNodes,
    Offset offset,
    int start,
    int end, [
    Map<String, Rect>? rectCache,
  ]) {
    // Create rect cache for this operation if not provided
    rectCache ??= {};

    if (start < 0 && end >= sortedNodes.length) {
      return null;
    }

    var min = _findCloseNode(
      sortedNodes,
      start,
      end,
      rectCache: rectCache,
      match: (index, rect) {
        final isMatch = rect.contains(offset);
        AppFlowyEditorLog.selection.debug(
          'findNodeInOffset: $index, rect: $rect, offset: $offset, isMatch: $isMatch',
        );
        return isMatch;
      },
      compare: (index, rect) => rect.bottom <= offset.dy,
    );

    final rowBottom = _getCachedRect(sortedNodes[min], rectCache).bottom;
    final filteredNodes = <Node>[];
    for (final node in sortedNodes) {
      if (_getCachedRect(node, rectCache).bottom == rowBottom) {
        filteredNodes.add(node);
      }
    }
    min = 0;
    if (filteredNodes.length > 1) {
      min = _findCloseNode(
        filteredNodes,
        0,
        filteredNodes.length - 1,
        rectCache: rectCache,
        match: (index, rect) {
          final isMatch = rect.contains(offset);
          AppFlowyEditorLog.selection.debug(
            'findNodeInOffset: $index, rect: $rect, offset: $offset, isMatch: $isMatch',
          );
          return isMatch;
        },
        compare: (index, rect) => rect.right <= offset.dx,
      );
    }

    final node = filteredNodes[min];
    if (node.children.isNotEmpty) {
      // First, filter out invisible children (Offstage or Opacity 0)
      // This must happen BEFORE checking rect conditions
      final visibleChildren = <Node>[];
      for (final child in node.children) {
        final context = child.key.currentContext;
        var isVisible = true;
        context?.visitAncestorElements((element) {
          final widget = element.widget;
          if (widget is Opacity && widget.opacity == 0) {
            isVisible = false;
            return false;
          }
          if (widget is Offstage && widget.offstage) {
            isVisible = false;
            return false;
          }
          return true;
        });
        if (isVisible) {
          visibleChildren.add(child);
        }
      }

      // Now check if any visible child's rect contains the offset
      if (visibleChildren.isNotEmpty &&
          _getCachedRect(visibleChildren.first, rectCache).top <= offset.dy) {
        final skipSortingChildren =
            node.selectable?.skipSortingChildrenWhenSelecting ?? false;

        List<Node> children;

        if (skipSortingChildren) {
          children = visibleChildren;
        } else {
          children = visibleChildren.toList(growable: false)
            ..sort(
              (a, b) {
                final aRect = _getCachedRect(a, rectCache!);
                final bRect = _getCachedRect(b, rectCache);
                return aRect.bottom != bRect.bottom
                    ? aRect.bottom.compareTo(bRect.bottom)
                    : aRect.left.compareTo(bRect.left);
              },
            );
        }

        if (children.isEmpty) {
          return node;
        }

        return getNodeInOffset(
          children,
          offset,
          0,
          children.length - 1,
          rectCache,
        );
      }
    }
    return node;
  }

  /// Get cached rect for a node, computing and caching if not present
  Rect _getCachedRect(Node node, Map<String, Rect> cache) {
    return cache.putIfAbsent(node.id, () => node.rect);
  }

  int _findCloseNode(
    List<Node> sortedNodes,
    int start,
    int end, {
    required Map<String, Rect> rectCache,
    bool Function(int index, Rect rect)? match,
    required bool Function(int index, Rect rect) compare,
  }) {
    for (var i = start; i <= end; i++) {
      final rect = _getCachedRect(sortedNodes[i], rectCache);
      if (match != null && match(i, rect)) {
        return i;
      }
    }

    var min = start;
    var max = end;
    while (min <= max) {
      final mid = min + ((max - min) >> 1);
      final rect = _getCachedRect(sortedNodes[mid], rectCache);
      if (compare(mid, rect)) {
        min = mid + 1;
      } else {
        max = mid - 1;
      }
    }

    return min.clamp(start, end);
  }
}
