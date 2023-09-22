import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/flutter/overlay.dart';
import 'package:appflowy_editor/src/service/selection/selection_gesture.dart';
import 'package:flutter/material.dart' hide Overlay, OverlayEntry;
import 'package:provider/provider.dart';

class DesktopSelectionServiceWidget extends StatefulWidget {
  const DesktopSelectionServiceWidget({
    super.key,
    this.cursorColor = const Color(0xFF00BCF0),
    this.selectionColor = const Color(0xFF00BCF0),
    required this.contextMenuItems,
    required this.child,
  });

  final Widget child;
  final Color cursorColor;
  final Color selectionColor;
  final List<List<ContextMenuItem>> contextMenuItems;

  @override
  State<DesktopSelectionServiceWidget> createState() =>
      _DesktopSelectionServiceWidgetState();
}

class _DesktopSelectionServiceWidgetState
    extends State<DesktopSelectionServiceWidget>
    with WidgetsBindingObserver
    implements AppFlowySelectionService {
  @override
  List<Rect> get selectionRects => editorState.selectionRects();
  final List<OverlayEntry> _selectionAreas = [];
  final List<OverlayEntry> _cursorAreas = [];
  final List<OverlayEntry> _contextMenuAreas = [];

  @override
  ValueNotifier<Selection?> currentSelection = ValueNotifier(null);

  @override
  List<Node> get currentSelectedNodes => editorState.getSelectedNodes();

  final List<SelectionGestureInterceptor> _interceptors = [];

  /// Pan
  Offset? _panStartOffset;
  double? _panStartScrollDy;

  Position? _panStartPosition;

  late EditorState editorState = Provider.of<EditorState>(
    context,
    listen: false,
  );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    editorState.selectionNotifier.addListener(_updateSelection);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    // Need to refresh the selection when the metrics changed.
    if (currentSelection.value != null) {
      Debounce.debounce(
        'didChangeMetrics - update selection ',
        const Duration(milliseconds: 100),
        () => updateSelection(currentSelection.value!),
      );
    }
  }

  @override
  void dispose() {
    clearSelection();
    WidgetsBinding.instance.removeObserver(this);
    editorState.selectionNotifier.removeListener(_updateSelection);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SelectionGestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTapDown: _onTapDown,
      onSecondaryTapDown: _onSecondaryTapDown,
      onDoubleTapDown: _onDoubleTapDown,
      onTripleTapDown: _onTripleTapDown,
      child: widget.child,
    );
  }

  @override
  void updateSelection(Selection? selection) {
    if (currentSelection.value == selection) {
      return;
    }

    currentSelection.value = selection;
    editorState.updateSelectionWithReason(
      selection,
      reason: SelectionUpdateReason.uiEvent,
    );
  }

  @override
  void clearSelection() {
    // currentSelectedNodes = [];
    currentSelection.value = null;

    _clearSelection();
  }

  void _clearSelection() {
    clearCursor();
    // clear selection areas
    _selectionAreas
      ..forEach((overlay) => overlay.remove())
      ..clear();

    // clear context menu
    _clearContextMenu();
  }

  @override
  void clearCursor() {
    // clear cursor areas
    _cursorAreas
      ..forEach((overlay) => overlay.remove())
      ..clear();
  }

  void _clearContextMenu() {
    _contextMenuAreas
      ..forEach((overlay) => overlay.remove())
      ..clear();
  }

  @override
  Node? getNodeInOffset(Offset offset) {
    final List<Node> sortedNodes = getVisibleNodes();

    return _getNodeInOffset(
      sortedNodes,
      offset,
      0,
      sortedNodes.length - 1,
    );
  }

  List<Node> getVisibleNodes() {
    final List<Node> sortedNodes = [];
    final positions =
        context.read<EditorScrollController>().visibleRangeNotifier.value;
    final min = positions.$1;
    final max = positions.$2;
    if (min < 0 || max < 0) {
      return sortedNodes;
    }

    int i = -1;
    for (final child in editorState.document.root.children) {
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

  @override
  Position? getPositionInOffset(Offset offset) {
    final node = getNodeInOffset(offset);
    final selectable = node?.selectable;
    if (selectable == null) {
      clearSelection();
      return null;
    }
    return selectable.getPositionInOffset(offset);
  }

  void _onTapDown(TapDownDetails details) {
    _clearContextMenu();

    final canTap = _interceptors.every(
      (element) => element.canTap?.call(details) ?? true,
    );
    if (!canTap) return;

    // clear old state.
    _panStartOffset = null;

    final offset = details.globalPosition;
    final node = getNodeInOffset(offset);
    final selectable = node?.selectable;
    if (selectable == null) {
      clearSelection();
      return;
    }
    final selection = selectable.cursorStyle == CursorStyle.verticalLine
        ? Selection.collapsed(
            selectable.getPositionInOffset(offset),
          )
        : Selection(
            start: selectable.start(),
            end: selectable.end(),
          );
    updateSelection(selection);
  }

  void _onDoubleTapDown(TapDownDetails details) {
    final offset = details.globalPosition;
    final node = getNodeInOffset(offset);
    final selection = node?.selectable?.getWordBoundaryInOffset(offset);
    if (selection == null) {
      clearSelection();
      return;
    }
    updateSelection(selection);
  }

  void _onTripleTapDown(TapDownDetails details) {
    final offset = details.globalPosition;
    final node = getNodeInOffset(offset);
    final selectable = node?.selectable;
    if (selectable == null) {
      clearSelection();
      return;
    }
    Selection selection = Selection(
      start: selectable.start(),
      end: selectable.end(),
    );
    updateSelection(selection);
  }

  void _onSecondaryTapDown(TapDownDetails details) {
    // if selection is null, or
    // selection.isCollapsed and the selected node is TextNode.
    // try to select the word.
    final selection = editorState.selectionNotifier.value;
    if (selection == null ||
        (selection.isCollapsed == true &&
            currentSelectedNodes.first.delta != null)) {
      _onDoubleTapDown(details);
    }

    _showContextMenu(details);
  }

  void _onPanStart(DragStartDetails details) {
    clearSelection();

    _panStartOffset = details.globalPosition.translate(-3.0, 0);
    _panStartScrollDy = editorState.service.scrollService?.dy;

    _panStartPosition = getNodeInOffset(_panStartOffset!)
        ?.selectable
        ?.getPositionInOffset(_panStartOffset!);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_panStartOffset == null ||
        _panStartScrollDy == null ||
        _panStartPosition == null) {
      return;
    }

    final panEndOffset = details.globalPosition;
    final dy = editorState.service.scrollService?.dy;
    final panStartOffset = dy == null
        ? _panStartOffset!
        : _panStartOffset!.translate(0, _panStartScrollDy! - dy);

    // this one maybe redundant.
    final last = getNodeInOffset(panEndOffset)?.selectable;

    // compute the selection in range.
    if (last != null) {
      final start = _panStartPosition!;
      final end = last.getSelectionInRange(panStartOffset, panEndOffset).end;
      final selection = Selection(start: start, end: end);
      updateSelection(selection);
    }

    editorState.service.scrollService?.startAutoScroll(
      panEndOffset,
      edgeOffset: 100,
    );
  }

  void _onPanEnd(DragEndDetails details) {
    _panStartPosition = null;

    editorState.service.scrollService?.stopAutoScroll();
  }

  void _updateSelection() {}

  void _showContextMenu(TapDownDetails details) {
    _clearContextMenu();

    // only shows around the selection area.
    if (selectionRects.isEmpty) {
      return;
    }

    final isHitSelectionAreas = currentSelection.value?.isCollapsed == true ||
        selectionRects.any((element) {
          const threshold = 20;
          final scaledArea = Rect.fromCenter(
            center: element.center,
            width: element.width + threshold,
            height: element.height + threshold,
          );
          return scaledArea.contains(details.globalPosition);
        });
    if (!isHitSelectionAreas) {
      return;
    }

    // For now, only support the text node.
    if (!currentSelectedNodes.every((element) => element.delta != null)) {
      return;
    }

    final baseOffset =
        editorState.renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final offset = details.globalPosition + const Offset(10, 10) - baseOffset;
    final contextMenu = OverlayEntry(
      builder: (context) => ContextMenu(
        position: offset,
        editorState: editorState,
        items: widget.contextMenuItems,
        onPressed: () => _clearContextMenu(),
      ),
    );

    _contextMenuAreas.add(contextMenu);
    Overlay.of(context)?.insert(contextMenu);
  }

  Node? _getNodeInOffset(
    List<Node> sortedNodes,
    Offset offset,
    int start,
    int end,
  ) {
    if (start < 0 && end >= sortedNodes.length) {
      return null;
    }

    var min = _findCloseNode(
      sortedNodes,
      start,
      end,
      (rect) => rect.bottom <= offset.dy,
    );

    final filteredNodes = List.of(sortedNodes)
      ..retainWhere((n) => n.rect.bottom == sortedNodes[min].rect.bottom);
    min = 0;
    if (filteredNodes.length > 1) {
      min = _findCloseNode(
        sortedNodes,
        0,
        filteredNodes.length - 1,
        (rect) => rect.right <= offset.dx,
      );
    }

    final node = filteredNodes[min];
    if (node.children.isNotEmpty &&
        node.children.first.renderBox != null &&
        node.children.first.rect.top <= offset.dy) {
      final children = node.children.toList(growable: false)
        ..sort(
          (a, b) => a.rect.bottom != b.rect.bottom
              ? a.rect.bottom.compareTo(b.rect.bottom)
              : a.rect.left.compareTo(b.rect.left),
        );

      return _getNodeInOffset(
        children,
        offset,
        0,
        children.length - 1,
      );
    }
    return node;
  }

  int _findCloseNode(
    List<Node> sortedNodes,
    int start,
    int end,
    bool Function(Rect rect) compare,
  ) {
    var min = start;
    var max = end;
    while (min <= max) {
      final mid = min + ((max - min) >> 1);
      final rect = sortedNodes[mid].rect;
      if (compare(rect)) {
        min = mid + 1;
      } else {
        max = mid - 1;
      }
    }
    return min.clamp(start, end);
  }

  /*void _showDebugLayerIfNeeded() {
     remove false to show debug overlay.
     if (kDebugMode && false) {
       _debugOverlay?.remove();
       if (offset != null) {
         _debugOverlay = OverlayEntry(
           builder: (context) => Positioned.fromRect(
             rect: Rect.fromPoints(offset, offset.translate(20, 20)),
             child: Container(
               color: Colors.red.withOpacity(0.2),
             ),
           ),
         );
         Overlay.of(context)?.insert(_debugOverlay!);
       } else if (_panStartOffset != null) {
         _debugOverlay = OverlayEntry(
           builder: (context) => Positioned.fromRect(
             rect: Rect.fromPoints(
                 _panStartOffset?.translate(
                       0,
                       -(editorState.service.scrollService!.dy -
                           _panStartScrollDy!),
                     ) ??
                     Offset.zero,
                 offset ?? Offset.zero),
             child: Container(
               color: Colors.red.withOpacity(0.2),
             ),
           ),
         );
         Overlay.of(context)?.insert(_debugOverlay!);
       } else {
         _debugOverlay = null;
       }
     }
  }*/

  @override
  void registerGestureInterceptor(SelectionGestureInterceptor interceptor) {
    _interceptors.add(interceptor);
  }

  @override
  void unregisterGestureInterceptor(String key) {
    _interceptors.removeWhere((element) => element.key == key);
  }
}
