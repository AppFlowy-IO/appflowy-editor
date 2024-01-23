import 'dart:math' as math;

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/selection/mobile_selection_service.dart';
import 'package:appflowy_editor/src/flutter/overlay.dart';
import 'package:appflowy_editor/src/service/selection/selection_gesture.dart';
import 'package:flutter/material.dart' hide Overlay, OverlayEntry;
import 'package:flutter/services.dart';
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
  ValueNotifier<Selection?> currentDragAndDropSelection = ValueNotifier(null);

  @override
  List<Node> get currentSelectedNodes => editorState.getSelectedNodes();

  final List<SelectionGestureInterceptor> _interceptors = [];

  /// Pan
  Offset? _panStartOffset;
  double? _panStartScrollDy;

  Position? _panStartPosition;

  final Set<SelectableMixin<StatefulWidget>> _dragAndDropSelectables = {};
  final Set<Rect> _dragAndDropSelectionRects = {};
  bool _isCursorPointValid = false;

  // cursor position calculated during drag and drop op.
  double cursorX = 0;
  double cursorY = 0;

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
    currentSelection.dispose();

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
    currentSelection.value = selection;
    editorState.updateSelectionWithReason(
      selection,
      reason: SelectionUpdateReason.uiEvent,
    );
  }

  void updateDragAndDropSelection(Selection? selection) {
    currentDragAndDropSelection.value = selection;
    editorState.updateDragAndDropSelectionWithReason(
      selection,
      reason: SelectionUpdateReason.uiEvent,
    );
  }

  void updateMouseCursorStyle(SystemMouseCursor cursorStyle) {
    editorState.updateMouseCursorStyle(cursorStyle);
  }

  void updateCursorStyle(CursorStyle cursorStyle) {
    editorState.updateCursorStyle(cursorStyle);
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
    // https://github.com/AppFlowy-IO/AppFlowy/issues/3651
    final min = math.max(positions.$1 - 1, 0);
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

  @override
  Selection? onPanStart(
    DragStartDetails details,
    MobileSelectionDragMode mode,
  ) {
    throw UnimplementedError();
  }

  @override
  Selection? onPanUpdate(
    DragUpdateDetails details,
    MobileSelectionDragMode mode,
  ) {
    throw UnimplementedError();
  }

  @override
  void onPanEnd(
    DragEndDetails details,
    MobileSelectionDragMode mode,
  ) {
    throw UnimplementedError();
  }

  // resets the presets after drag and drop op.
  void reset() {
    cursorX = cursorY = 0;

    _cachedDragAndDropSelectionRects = null;
    _dragAndDropSelectionRects.clear();

    _cachedDragAndDropSelectables = null;
    _dragAndDropSelectables.clear();

    clearSelection();
    updateCursorStyle(CursorStyle.verticalLine);
    updateMouseCursorStyle(SystemMouseCursors.text);
    updateDragAndDropSelection(null);
  }

  bool isCursorInSelection(double dx, double dy, Rect rect) {
    if (dx > rect.right ||
        dx < rect.left ||
        dy < rect.top ||
        dy > rect.bottom) {
      return false;
    }
    return true;
  }

  Rect calculateRect(SelectableMixin<StatefulWidget> selectable) {
    final rects =
        selectable.getRectsInSelection(currentDragAndDropSelection.value!);

    double left = 0.0, top = 0.0, right = 0.0, bottom = 0.0;
    for (final rect in rects) {
      left = math.min(left, rect.left);
      right = math.max(right, rect.right);
      top = math.min(top, rect.top);
      bottom = math.max(bottom, rect.bottom);
    }

    final leftTopOffset = selectable.localToGlobal(Offset(left, top));
    final topRightOffset = selectable.localToGlobal(Offset(right, top));
    final rightBottomOffset = selectable.localToGlobal(Offset(right, bottom));

    left = leftTopOffset.dx;
    top = leftTopOffset.dy;
    right = topRightOffset.dx;
    bottom = rightBottomOffset.dy;

    return Rect.fromLTRB(left, top, right, bottom);
  }

  List<Rect>? _cachedDragAndDropSelectionRects;

  List<Rect> get dragAndDropSelectionRects {
    _cachedDragAndDropSelectionRects ??=
        _dragAndDropSelectionRects.toList(growable: false);
    return _cachedDragAndDropSelectionRects!;
  }

  set dragAndDropSelectionRect(Rect rect) {
    if (_dragAndDropSelectionRects.contains(rect)) return;

    _dragAndDropSelectionRects.add(rect);
    _cachedDragAndDropSelectionRects = null;
  }

  List<SelectableMixin<StatefulWidget>>? _cachedDragAndDropSelectables;

  List<SelectableMixin<StatefulWidget>> get dragAndDropSelectables {
    _cachedDragAndDropSelectables ??=
        _dragAndDropSelectables.toList(growable: false);
    return _cachedDragAndDropSelectables!;
  }

  set dragAndDropSelectable(SelectableMixin<StatefulWidget> selectable) {
    if (_dragAndDropSelectables.contains(selectable)) return;

    _dragAndDropSelectables.add(selectable);
    _cachedDragAndDropSelectables = null;
    _cachedDragAndDropSelectionRects = null;
  }

  void _onTapDown(TapDownDetails details) {
    _clearContextMenu();

    final canTap = _interceptors.every(
      (element) => element.canTap?.call(details) ?? true,
    );
    if (!canTap) {
      reset();
      return updateSelection(null);
    }

    final offset = details.globalPosition;
    final node = getNodeInOffset(offset);
    final selectable = node?.selectable;

    if (currentDragAndDropSelection.value != null) {
      if (_cachedDragAndDropSelectionRects == null) {
        for (final selectable in dragAndDropSelectables) {
          dragAndDropSelectionRect = calculateRect(selectable);
        }
      }

      cursorX = offset.dx;
      cursorY = offset.dy;

      for (final rect in dragAndDropSelectionRects) {
        if (isCursorInSelection(cursorX, cursorY, rect)) {
          _isCursorPointValid = true;
          return;
        }
      }
    }

    if (selectable == null) {
      // Clear old start offset
      _panStartOffset = null;
      return clearSelection();
    }

    Selection? selection;
    if (RawKeyboard.instance.isShiftPressed && _panStartOffset != null) {
      final first = getNodeInOffset(_panStartOffset!)?.selectable;

      if (first != null) {
        final start = first.getSelectionInRange(_panStartOffset!, offset).start;
        final end =
            selectable.getSelectionInRange(_panStartOffset!, offset).end;

        selection = Selection(start: start, end: end);
      }
    } else {
      selection = selectable.cursorStyle == CursorStyle.verticalLine
          ? Selection.collapsed(selectable.getPositionInOffset(offset))
          : Selection(start: selectable.start(), end: selectable.end());

      // Reset old start offset
      _panStartOffset = offset;
    }

    updateSelection(selection);

    // need to cancel drag and drop op. selection
    // on single tap down event.
    reset();
  }

  void _onDoubleTapDown(TapDownDetails details) {
    final offset = details.globalPosition;
    final node = getNodeInOffset(offset);
    final selectable = node?.selectable;
    final selection = selectable?.getWordBoundaryInOffset(offset);
    if (selection == null) {
      clearSelection();
      return;
    }
    dragAndDropSelectable = selectable!;
    updateDragAndDropSelection(selection);
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
    dragAndDropSelectable = selectable;
    updateDragAndDropSelection(selection);
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

    final dy = editorState.service.scrollService?.dy;

    if (_isCursorPointValid) {
      final selection = currentDragAndDropSelection.value;
      if (selection == null) {
        return;
      }

      cursorX = details.globalPosition.dx;
      cursorY = details.globalPosition.dy;

      panCursor(details.globalPosition, selection);
      return;
    }

    final panEndOffset = details.globalPosition;
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
      dragAndDropSelectable = last;
      updateSelection(selection);
      updateDragAndDropSelection(selection);
    }

    editorState.service.scrollService?.startAutoScroll(
      panEndOffset,
      edgeOffset: 100,
    );
  }

  void _onPanEnd(DragEndDetails details) {
    _panStartPosition = null;

    editorState.service.scrollService?.stopAutoScroll();

    if (_isCursorPointValid) {
      for (final rect in dragAndDropSelectionRects) {
        if (!isCursorInSelection(cursorX, cursorY, rect)) {
          moveSelection(
            currentDragAndDropSelection.value,
            currentSelection.value,
          );
        }
      }
      reset();
      _isCursorPointValid = false;
    }
  }

  void _updateSelection() {
    final selection = editorState.selectionNotifier.value;
    if (selection == null) {
      clearSelection();
    }
  }

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

  void panCursor(Offset offset, Selection selection) {
    final node = getNodeInOffset(offset);
    final selectable = node?.selectable;
    if (selectable == null) {
      reset();
      return;
    }

    updateCursorStyle(CursorStyle.dottedVerticalLine);
    updateMouseCursorStyle(SystemMouseCursors.basic);
    updateSelection(
      Selection.collapsed(
        selectable.getPositionInOffset(offset),
      ),
    );
  }

  void moveSelection(Selection? selection, Selection? cursorPosition) {
    if (selection == null || cursorPosition == null) return;

    final fromNode = editorState.getNodeAtPath(selection.start.path);
    final toNode = editorState.getNodeAtPath(cursorPosition.start.path);
    if (fromNode == null || toNode == null) return;

    List<String> textInSelection = editorState.getTextInSelection(selection);
    int len = 0;

    if (selection.isBackward) {
      textInSelection = textInSelection.reversed.toList();
    }

    for (final text in textInSelection) {
      len += text.length;
      editorState.insertText(cursorPosition.start.offset, text, node: toNode);
    }

    Selection newCursorPosition = cursorPosition;

    // Update the offset of the selection if:
    //
    // The selection is at the same node, and
    // The drop cursor position is before the selection.
    //
    int end = selection.endIndex;
    if (selection.isForward) {
      end = selection.startIndex;
    }
    if (fromNode == toNode && cursorPosition.startIndex < end) {
      final newStartPosition = Position(
        path: fromNode.path,
        offset: selection.start.offset + len,
      );
      final newEndPosition = Position(
        path: fromNode.path,
        offset: selection.end.offset + len,
      );

      selection = Selection(
        start: newStartPosition,
        end: newEndPosition,
      );

      newCursorPosition = Selection.collapsed(
        Position(
          path: toNode.path,
          offset: len,
        ),
      );
    }

    editorState.deleteSelection(selection);

    if (fromNode != toNode) {
      newCursorPosition = Selection.collapsed(
        Position(
          path: toNode.path,
          offset: len,
        ),
      );
    }

    // update the cursor position to the
    // last of the edited [toNode] path after the op.
    updateSelection(newCursorPosition);
  }

  @override
  void registerGestureInterceptor(SelectionGestureInterceptor interceptor) {
    _interceptors.add(interceptor);
  }

  @override
  void unregisterGestureInterceptor(String key) {
    _interceptors.removeWhere((element) => element.key == key);
  }
}
