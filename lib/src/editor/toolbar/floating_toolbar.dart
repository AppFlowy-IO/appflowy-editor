import 'dart:math';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// A floating toolbar that displays at the top of the editor when the selection
///   and will be hidden when the selection is collapsed.
///
class FloatingToolbar extends StatefulWidget {
  const FloatingToolbar({
    super.key,
    required this.editorState,
    required this.scrollController,
    required this.child,
  });

  final EditorState editorState;
  final ScrollController scrollController;
  final Widget child;

  @override
  State<FloatingToolbar> createState() => _FloatingToolbarState();
}

class _FloatingToolbarState extends State<FloatingToolbar> {
  OverlayEntry? _toolbarContainer;

  EditorState get editorState => widget.editorState;

  @override
  void initState() {
    super.initState();

    editorState.selectionNotifier.addListener(_onSelectionChanged);

    widget.scrollController.addListener(_onScrollPositionChanged);
  }

  @override
  void dispose() {
    editorState.selectionNotifier.removeListener(_onSelectionChanged);
    widget.scrollController.removeListener(_onScrollPositionChanged);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _onSelectionChanged() {
    final selection = editorState.selection;
    if (selection == null || selection.isCollapsed) {
      _clear();
    } else {
      // uses debounce to avoid the computing the rects too frequently.
      _showAfter(const Duration(milliseconds: 200));
    }
  }

  void _onScrollPositionChanged() {
    final offset = widget.scrollController.offset;
    Log.toolbar.debug('offset = $offset');

    _clear();
    _showAfter(Duration.zero);
  }

  final String _debounceKey = 'show the toolbar';
  void _clear() {
    Debounce.cancel(_debounceKey);

    _toolbarContainer?.remove();
    _toolbarContainer = null;
  }

  void _showAfter([Duration duration = Duration.zero]) {
    _clear(); // clear the previous toolbar

    // uses debounce to avoid the computing the rects too frequently.
    Debounce.debounce(
      _debounceKey,
      duration,
      () {
        _showToolbar();
      },
    );
  }

  void _showToolbar() {
    final rects = _computeSelectionRects();
    if (rects.isEmpty) {
      return;
    }

    final offset = _findSuitableOffset(rects.map((e) => e.topLeft));
    _toolbarContainer = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: offset.dx,
          top: max(0, offset.dy) - 30,
          child: _buildToolbar(context),
        );
      },
    );
    Overlay.of(context).insert(_toolbarContainer!);
  }

  Widget _buildToolbar(BuildContext context) {
    return Container(
      width: 300,
      height: 30,
      color: Colors.red,
    );
  }

  /// Compute the rects of the selection.
  List<Rect> _computeSelectionRects() {
    final selection = editorState.selection;
    if (selection == null || selection.isCollapsed) {
      return [];
    }

    final nodes = editorState.getNodesInSelection(selection);
    final rects = <Rect>[];
    for (final node in nodes) {
      final selectable = node.selectable;
      if (selectable == null) {
        continue;
      }
      final nodeRects = selectable.getRectsInSelection(selection);
      if (nodeRects.isEmpty) {
        continue;
      }
      final renderBox = node.renderBox;
      if (renderBox == null) {
        continue;
      }
      for (final rect in nodeRects) {
        final globalOffset = renderBox.localToGlobal(rect.topLeft);
        rects.add(globalOffset & rect.size);
      }
    }

    /*
    final rects = nodes
        .map(
          (node) => node.selectable
              ?.getRectsInSelection(selection)
              .map(
                (rect) => node.renderBox?.localToGlobal(rect.topLeft),
              )
              .whereNotNull(),
        )
        .whereNotNull()
        .expand((element) => element)
        .toList();
    */

    return rects;
  }

  Offset _findSuitableOffset(Iterable<Offset> offsets) {
    assert(offsets.isNotEmpty);

    // find the min offset with non-negative dy.
    final offsetsWithNonNegativeDy =
        offsets.where((element) => element.dy >= 30);
    if (offsetsWithNonNegativeDy.isEmpty) {
      // if all the rects offset is negative, then the selection is not visible.
      return offsets.last;
    }

    final minOffset = offsetsWithNonNegativeDy.reduce((min, current) {
      if (min.dy < current.dy) {
        return min;
      } else if (min.dy == current.dy) {
        return min.dx < current.dx ? min : current;
      } else {
        return current;
      }
    });

    return minOffset;
  }
}
