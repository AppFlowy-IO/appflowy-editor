import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

/// A floating toolbar that displays at the top of the editor when the selection
///   and will be hidden when the selection is collapsed.
///
class FloatingToolbar extends StatefulWidget {
  const FloatingToolbar({
    super.key,
    required this.editorState,
    required this.child,
  });

  final EditorState editorState;
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      editorState.service.scrollService?.scrollController
          .addListener(_onScrollPositionChanged);
    });
  }

  @override
  void dispose() {
    editorState.selectionNotifier.removeListener(_onSelectionChanged);
    editorState.service.scrollService?.scrollController
        .removeListener(_onScrollPositionChanged);

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
      _show();
    }
  }

  void _onScrollPositionChanged() {
    final offset = editorState.service.scrollService?.scrollController.offset;
    if (offset != null) {
      Log.toolbar.debug('offset = $offset');
      _show();
    }
  }

  final String _debounceKey = 'show the toolbar';
  void _clear() {
    Debounce.cancel(_debounceKey);

    _toolbarContainer?.remove();
    _toolbarContainer = null;
  }

  void _show() {
    _clear(); // clear the previous toolbar

    // uses debounce to avoid the computing the rects too frequently.
    Debounce.debounce(
      _debounceKey,
      const Duration(milliseconds: 200),
      () {
        final rects = _computeSelectionRects();
        if (rects.isNotEmpty) {
          Log.toolbar.debug('rects = $rects');
        }
      },
    );
  }

  /// Compute the rects of the selection.
  List<Offset> _computeSelectionRects() {
    final selection = editorState.selection;
    if (selection == null || selection.isCollapsed) {
      return [];
    }
    final nodes = editorState.getNodesInSelection(selection);
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

    return rects;
  }
}
