import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class MobileFloatingToolbarItem {
  const MobileFloatingToolbarItem({
    required this.builder,
  });

  final WidgetBuilder builder;
}

/// A mobile floating toolbar that displays at the top of the editor when the selection is not collapsed.
///   and will be hidden when the selection is collapsed.
///
/// Normally, it will show copy, cut, paste.
class MobileFloatingToolbar extends StatefulWidget {
  const MobileFloatingToolbar({
    super.key,
    required this.editorState,
    required this.editorScrollController,
    required this.child,
    required this.toolbarBuilder,
  });

  final EditorState editorState;
  final EditorScrollController editorScrollController;
  final Widget child;
  final Widget Function(BuildContext context, Offset anchor) toolbarBuilder;

  @override
  State<MobileFloatingToolbar> createState() => _MobileFloatingToolbarState();
}

class _MobileFloatingToolbarState extends State<MobileFloatingToolbar>
    with WidgetsBindingObserver {
  OverlayEntry? _toolbarContainer;

  EditorState get editorState => widget.editorState;

  bool _isToolbarVisible = false;
  // use for skipping the first build for the toolbar when the selection is collapsed.
  Selection? prevSelection;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    editorState.selectionNotifier.addListener(_onSelectionChanged);
    widget.editorScrollController.offsetNotifier.addListener(
      _onScrollPositionChanged,
    );
  }

  @override
  void didUpdateWidget(MobileFloatingToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.editorState != oldWidget.editorState) {
      editorState.selectionNotifier.addListener(_onSelectionChanged);
    }
  }

  @override
  void dispose() {
    editorState.selectionNotifier.removeListener(_onSelectionChanged);
    widget.editorScrollController.offsetNotifier.removeListener(
      _onScrollPositionChanged,
    );
    WidgetsBinding.instance.removeObserver(this);

    _clear();

    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();

    _clear();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _onSelectionChanged() {
    final selection = editorState.selection;
    final selectionType = editorState.selectionType;
    if (selection == null || selectionType == SelectionType.block) {
      _clear();
    } else if (selection.isCollapsed) {
      if (_isToolbarVisible) {
        _clear();
      } else if (prevSelection == selection) {
        _showAfterDelay(const Duration(milliseconds: 400));
      }
      prevSelection = selection;
    } else {
      // uses debounce to avoid the computing the rects too frequently.
      _showAfterDelay(const Duration(milliseconds: 400));
    }
  }

  void _onScrollPositionChanged() {
    _clear();
  }

  final String _debounceKey = 'show the toolbar';
  void _clear() {
    Debounce.cancel(_debounceKey);

    _toolbarContainer?.remove();
    _toolbarContainer = null;
    _isToolbarVisible = false;
    prevSelection = null;
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
    final rects = editorState.selectionRects();
    if (rects.isEmpty) {
      return;
    }

    final rect = _findSuitableRect(rects);
    _toolbarContainer = OverlayEntry(
      builder: (context) {
        return _buildToolbar(
          context,
          rect.topCenter,
        );
      },
    );
    Overlay.of(context).insert(_toolbarContainer!);
    _isToolbarVisible = true;
  }

  Widget _buildToolbar(
    BuildContext context,
    Offset offset,
  ) {
    return widget.toolbarBuilder(context, offset);
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
    final left = (rect.left - editorOffset.dx).abs();
    final right = (rect.right - editorOffset.dx).abs();
    final width = editorSize.width;
    final threshold = width / 3.0;
    final top = rect.top < floatingToolbarHeight
        ? rect.bottom + floatingToolbarHeight
        : rect.top;
    if (left <= threshold) {
      // show in left
      return (rect.left, top, null);
    } else if (left >= threshold && right <= threshold * 2.0) {
      // show in center
      return (threshold, top, null);
    } else {
      // show in right
      return (null, top, editorRect.right - rect.right);
    }
  }
}
