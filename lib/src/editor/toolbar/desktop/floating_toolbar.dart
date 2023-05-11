import 'dart:math';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// A floating toolbar that displays at the top of the editor when the selection
///   and will be hidden when the selection is collapsed.
///
class FloatingToolbar extends StatefulWidget {
  const FloatingToolbar({
    super.key,
    required this.items,
    required this.editorState,
    required this.scrollController,
    required this.child,
  });

  final List<ToolbarItem> items;
  final EditorState editorState;
  final ScrollController scrollController;
  final Widget child;

  @override
  State<FloatingToolbar> createState() => _FloatingToolbarState();
}

class _FloatingToolbarState extends State<FloatingToolbar> {
  OverlayEntry? _toolbarContainer;
  FloatingToolbarWidget? _toolbarWidget;

  EditorState get editorState => widget.editorState;

  @override
  void initState() {
    super.initState();

    editorState.selectionNotifier.addListener(_onSelectionChanged);
    widget.scrollController.addListener(_onScrollPositionChanged);
  }

  @override
  void didUpdateWidget(FloatingToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.editorState != oldWidget.editorState) {
      editorState.selectionNotifier.addListener(_onSelectionChanged);
    }

    if (widget.scrollController != oldWidget.scrollController) {
      widget.scrollController.addListener(_onScrollPositionChanged);
    }
  }

  @override
  void dispose() {
    editorState.selectionNotifier.removeListener(_onSelectionChanged);
    widget.scrollController.removeListener(_onScrollPositionChanged);

    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();

    _clear();
    _toolbarWidget = null;
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
      _showAfterDelay(const Duration(milliseconds: 200));
    }

    // clear the toolbar widget
    _toolbarWidget = null;
  }

  void _onScrollPositionChanged() {
    final offset = widget.scrollController.offset;
    Log.toolbar.debug('offset = $offset');

    _clear();

    // TODO: optimize the toolbar showing logic, making it more smooth.
    // A quick idea: based on the scroll controller's offset to display the toolbar.
    _showAfterDelay(Duration.zero);
  }

  final String _debounceKey = 'show the toolbar';
  void _clear() {
    Debounce.cancel(_debounceKey);

    _toolbarContainer?.remove();
    _toolbarContainer = null;
  }

  void _showAfterDelay([Duration duration = Duration.zero]) {
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
    final rects = editorState.selectionRects;
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
    _toolbarWidget ??= FloatingToolbarWidget(
      items: widget.items,
      editorState: editorState,
    );
    return _toolbarWidget!;
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
