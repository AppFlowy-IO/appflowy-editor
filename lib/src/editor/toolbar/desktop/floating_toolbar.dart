import 'dart:math';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class FloatingToolbarStyle {
  const FloatingToolbarStyle({
    this.backgroundColor = Colors.black,
    this.toolbarActiveColor = Colors.lightBlue,
  });

  final Color backgroundColor;
  final Color toolbarActiveColor;
}

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
    this.style = const FloatingToolbarStyle(),
  });

  final List<ToolbarItem> items;
  final EditorState editorState;
  final ScrollController scrollController;
  final Widget child;
  final FloatingToolbarStyle style;

  @override
  State<FloatingToolbar> createState() => _FloatingToolbarState();
}

class _FloatingToolbarState extends State<FloatingToolbar>
    with WidgetsBindingObserver {
  OverlayEntry? _toolbarContainer;
  FloatingToolbarWidget? _toolbarWidget;

  EditorState get editorState => widget.editorState;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
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
    WidgetsBinding.instance.removeObserver(this);

    _clear();
    _toolbarWidget = null;

    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();

    _clear();
    _toolbarWidget = null;
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    _showAfterDelay();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _onSelectionChanged() {
    final selection = editorState.selection;
    final selectionType = editorState.selectionType;
    if (selection == null ||
        selection.isCollapsed ||
        selectionType == SelectionType.block) {
      _clear();
    } else {
      // uses debounce to avoid the computing the rects too frequently.
      _showAfterDelay(const Duration(milliseconds: 200));
    }
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
    // uses debounce to avoid the computing the rects too frequently.
    Debounce.debounce(
      _debounceKey,
      duration,
      () {
        _clear(); // clear the previous toolbar.
        _showToolbar();
      },
    );
  }

  void _showToolbar() {
    if (editorState.selection?.isCollapsed ?? true) {
      return;
    }
    final rects = editorState.selectionRects();
    if (rects.isEmpty) {
      return;
    }

    final rect = _findSuitableRect(rects);
    final (left, top, right) = calculateToolbarOffset(rect);
    _toolbarContainer = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: max(0, top) - floatingToolbarHeight,
          left: left,
          right: right,
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
      backgroundColor: widget.style.backgroundColor,
      toolbarActiveColor: widget.style.toolbarActiveColor,
    );
    return _toolbarWidget!;
  }

  Rect _findSuitableRect(Iterable<Rect> rects) {
    assert(rects.isNotEmpty);

    final editorOffset =
        editorState.renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;

    // find the min offset with non-negative dy.
    final rectsWithNonNegativeDy = rects.where(
      (element) => element.top >= editorOffset.dy,
    );
    if (rectsWithNonNegativeDy.isEmpty) {
      // if all the rects offset is negative, then the selection is not visible.
      return Rect.zero;
    }

    final minRect = rectsWithNonNegativeDy.reduce((min, current) {
      if (min.top < current.top) {
        return min;
      } else if (min.top == current.top) {
        return min.top < current.top ? min : current;
      } else {
        return current;
      }
    });

    return minRect;
  }

  (double? left, double top, double? right) calculateToolbarOffset(Rect rect) {
    final editorOffset =
        editorState.renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final editorSize = editorState.renderBox?.size ?? Size.zero;
    final editorRect = editorOffset & editorSize;
    final editorCenter = editorRect.center;
    final left = (rect.left - editorCenter.dx).abs();
    final right = (rect.right - editorCenter.dx).abs();
    final width = editorSize.width;
    final threshold = width / 3.0;
    final top = rect.top < floatingToolbarHeight
        ? rect.bottom + floatingToolbarHeight
        : rect.top;
    if (rect.left >= threshold && rect.right <= threshold * 2.0) {
      // show in center
      return (threshold, top, null);
    } else if (left >= right && rect.left <= threshold) {
      // show in left
      return (rect.left, top, null);
    } else {
      // show in right
      return (null, top, editorRect.right - rect.right);
    }
  }
}
