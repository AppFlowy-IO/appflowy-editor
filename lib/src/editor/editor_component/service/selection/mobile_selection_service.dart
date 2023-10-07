import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/flutter/overlay.dart';
import 'package:appflowy_editor/src/render/selection/mobile_selection_widget.dart';
import 'package:appflowy_editor/src/service/selection/mobile_selection_gesture.dart';
import 'package:flutter/material.dart' hide Overlay, OverlayEntry;
import 'package:provider/provider.dart';

enum MobileSelectionDragMode {
  none,
  leftSelectionHandler,
  rightSelectionHandler,
  cursor;
}

enum MobileSelectionHandlerType {
  leftHandler,
  rightHandler,
  cursorHandler,
}

class MobileSelectionServiceWidget extends StatefulWidget {
  const MobileSelectionServiceWidget({
    super.key,
    this.cursorColor = const Color(0xFF00BCF0),
    this.selectionColor = const Color.fromARGB(53, 111, 201, 231),
    required this.child,
  });

  final Widget child;
  final Color cursorColor;
  final Color selectionColor;

  @override
  State<MobileSelectionServiceWidget> createState() =>
      _MobileSelectionServiceWidgetState();
}

class _MobileSelectionServiceWidgetState
    extends State<MobileSelectionServiceWidget>
    with WidgetsBindingObserver
    implements AppFlowySelectionService {
  @override
  final List<Rect> selectionRects = [];
  final List<OverlayEntry> _selectionAreas = [];
  final List<OverlayEntry> _cursorAreas = [];

  @override
  ValueNotifier<Selection?> currentSelection = ValueNotifier(null);

  @override
  List<Node> currentSelectedNodes = [];

  final List<SelectionGestureInterceptor> _interceptors = [];

  /// Pan
  Offset? _panStartOffset;
  double? _panStartScrollDy;
  Selection? _panStartSelection;

  MobileSelectionDragMode dragMode = MobileSelectionDragMode.none;

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
  void dispose() {
    clearSelection();
    WidgetsBinding.instance.removeObserver(this);
    editorState.selectionNotifier.removeListener(_updateSelection);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MobileSelectionGestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTapUp: _onTapUp,
      onDoubleTapUp: _onDoubleTapUp,
      onTripleTapUp: _onTripleTapUp,
      child: widget.child,
    );
  }

  @override
  void updateSelection(Selection? selection) {
    if (currentSelection.value == selection) {
      return;
    }

    selectionRects.clear();
    _clearSelection();

    if (selection != null) {
      if (!selection.isCollapsed) {
        // updates selection area.
        Log.selection.debug('update cursor area, $selection');
        _updateSelectionAreas(selection);
      }
    }

    currentSelection.value = selection;
    editorState.updateSelectionWithReason(
      selection,
      reason: SelectionUpdateReason.uiEvent,
    );
  }

  @override
  void clearSelection() {
    currentSelectedNodes = [];
    currentSelection.value = null;

    _clearSelection();
  }

  void _clearSelection() {
    clearCursor();
    // clear selection areas
    _selectionAreas
      ..forEach((overlay) => overlay.remove())
      ..clear();
    // clear cursor areas
  }

  @override
  void clearCursor() {
    // clear cursor areas
    _cursorAreas
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

  @override
  void registerGestureInterceptor(SelectionGestureInterceptor interceptor) {
    _interceptors.add(interceptor);
  }

  @override
  void unregisterGestureInterceptor(String key) {
    _interceptors.removeWhere((element) => element.key == key);
  }

  void _updateSelection() {
    final selection = editorState.selection;
    if (currentSelection.value != selection) {
      return;
    }

    if (selection != null) {
      if (!selection.isCollapsed) {
        // updates selection area.
        Log.selection.debug('update cursor area, $selection');
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          selectionRects.clear();
          _clearSelection();
          _updateSelectionAreas(selection);
        });
      }
    }
  }

  void _onTapUp(TapUpDetails details) {
    // final canTap = _interceptors.every(
    //   (element) => element.canTap?.call(details) ?? true,
    // );
    // if (!canTap) return;

    clearSelection();

    // clear old state.
    _panStartOffset = null;

    final position = getPositionInOffset(details.globalPosition);
    if (position == null) {
      return;
    }

    editorState.selection = Selection.collapsed(position);
  }

  void _onDoubleTapUp(TapUpDetails details) {
    final offset = details.globalPosition;
    final node = getNodeInOffset(offset);
    final selection = node?.selectable?.getWordBoundaryInOffset(offset);
    if (selection == null) {
      clearSelection();
      return;
    }
    updateSelection(selection);
  }

  void _onTripleTapUp(TapUpDetails details) {
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

  void _onPanStart(DragStartDetails details) {
    _panStartOffset = details.globalPosition.translate(-3.0, 0);
    _panStartScrollDy = editorState.service.scrollService?.dy;

    final position = details.globalPosition;
    final selection = editorState.selection;
    _panStartSelection = selection;
    if (selection == null) {
      dragMode = MobileSelectionDragMode.none;
    } else if (selection.isCollapsed &&
        _isOverlayOnHandler(
          position,
          MobileSelectionHandlerType.cursorHandler,
        )) {
      dragMode = MobileSelectionDragMode.cursor;
    } else if (_isOverlayOnHandler(
      position,
      MobileSelectionHandlerType.leftHandler,
    )) {
      dragMode = MobileSelectionDragMode.leftSelectionHandler;
    } else if (_isOverlayOnHandler(
      position,
      MobileSelectionHandlerType.rightHandler,
    )) {
      dragMode = MobileSelectionDragMode.rightSelectionHandler;
    } else {
      dragMode = MobileSelectionDragMode.none;
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_panStartOffset == null || _panStartScrollDy == null) {
      return;
    }

    // only support selection mode now.
    final selection = editorState.selection;
    if (selection == null || dragMode == MobileSelectionDragMode.none) {
      return;
    }

    final panEndOffset = details.globalPosition;

    final dy = editorState.service.scrollService?.dy;
    final panStartOffset = dy == null
        ? _panStartOffset!
        : _panStartOffset!.translate(0, _panStartScrollDy! - dy);
    final end = getNodeInOffset(panEndOffset)
        ?.selectable
        ?.getSelectionInRange(panStartOffset, panEndOffset)
        .end;

    if (end != null) {
      if (dragMode == MobileSelectionDragMode.leftSelectionHandler) {
        updateSelection(
          Selection(
            start: _panStartSelection!.normalized.end,
            end: end,
          ).normalized,
        );
      } else if (dragMode == MobileSelectionDragMode.rightSelectionHandler) {
        updateSelection(
          Selection(
            start: _panStartSelection!.normalized.start,
            end: end,
          ).normalized,
        );
      } else if (dragMode == MobileSelectionDragMode.cursor) {
        updateSelection(
          Selection.collapsed(end),
        );
      }
    }
  }

  void _onPanEnd(DragEndDetails details) {
    // do nothing
  }

  void _updateSelectionAreas(Selection selection) {
    final nodes = editorState.getNodesInSelection(selection);

    currentSelectedNodes = nodes;

    final backwardNodes =
        selection.isBackward ? nodes : nodes.reversed.toList(growable: false);
    final normalizedSelection = selection.normalized;
    assert(normalizedSelection.isBackward);

    Log.selection.debug('update selection areas, $normalizedSelection');

    for (var i = 0; i < backwardNodes.length; i++) {
      final node = backwardNodes[i];

      final selectable = node.selectable;
      if (selectable == null) {
        continue;
      }

      var newSelection = normalizedSelection.copyWith();

      /// In the case of multiple selections,
      ///  we need to return a new selection for each selected node individually.
      ///
      /// < > means selected.
      /// text: abcd<ef
      /// text: ghijkl
      /// text: mn>opqr
      ///
      if (!normalizedSelection.isSingle) {
        if (i == 0) {
          newSelection = newSelection.copyWith(end: selectable.end());
        } else if (i == nodes.length - 1) {
          newSelection = newSelection.copyWith(start: selectable.start());
        } else {
          newSelection = Selection(
            start: selectable.start(),
            end: selectable.end(),
          );
        }
      }

      final rects = selectable.getRectsInSelection(
        newSelection,
        shiftWithBaseOffset: true,
      );
      for (var (j, rect) in rects.indexed) {
        final selectionRect = selectable.transformRectToGlobal(
          rect,
          shiftWithBaseOffset: true,
        );
        selectionRects.add(selectionRect);
        final showLeftHandler = i == 0 && j == 0;
        final showRightHandler =
            i == backwardNodes.length - 1 && j == rects.length - 1;
        if (rect.width <= 0) {
          rect = Rect.fromLTWH(rect.left, rect.top, 8.0, rect.height);
        }
        final overlay = OverlayEntry(
          builder: (context) => MobileSelectionWidget(
            color: Colors.transparent,
            layerLink: node.layerLink,
            rect: rect,
            showLeftHandler: showLeftHandler,
            showRightHandler: showRightHandler,
            handlerColor: editorState.editorStyle.cursorColor,
          ),
        );
        _selectionAreas.add(overlay);
      }
    }

    final overlay = Overlay.of(context);
    overlay?.insertAll(
      _selectionAreas,
    );
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
    var min = start;
    var max = end;
    while (min <= max) {
      final mid = min + ((max - min) >> 1);
      final rect = sortedNodes[mid].rect;
      if (rect.bottom <= offset.dy) {
        min = mid + 1;
      } else {
        max = mid - 1;
      }
    }
    min = min.clamp(start, end);
    final node = sortedNodes[min];
    if (node.children.isNotEmpty && node.children.first.rect.top <= offset.dy) {
      final children = node.children.toList(growable: false);
      return _getNodeInOffset(
        children,
        offset,
        0,
        children.length - 1,
      );
    }
    return node;
  }

  bool _isOverlayOnHandler(Offset point, MobileSelectionHandlerType type) {
    final selection = editorState.selection;
    if (selection == null) {
      return false;
    }

    SelectableMixin? selectable;
    Rect? rect;

    switch (type) {
      case MobileSelectionHandlerType.leftHandler:
      case MobileSelectionHandlerType.cursorHandler:
        selectable =
            editorState.getNodeAtPath(selection.start.path)?.selectable;
        if (selectable == null) {
          return false;
        }
        rect = selectable.getCursorRectInPosition(
          selection.start,
          shiftWithBaseOffset: true,
        );
        if (rect == null) {
          return false;
        }
        break;
      case MobileSelectionHandlerType.rightHandler:
        selectable = editorState.getNodeAtPath(selection.end.path)?.selectable;
        if (selectable == null) {
          return false;
        }
        rect = selectable.getCursorRectInPosition(
          selection.end,
          shiftWithBaseOffset: true,
        );
        if (rect == null) {
          return false;
        }
        break;
    }

    const extend = 20.0;
    final handlerRect = selectable.transformRectToGlobal(
      Rect.fromLTWH(
        rect.left - extend,
        rect.top - extend,
        extend * 2,
        rect.height + 2 * extend,
      ),
      shiftWithBaseOffset: true,
    );

    return handlerRect.contains(point);
  }
}
