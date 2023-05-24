import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/flutter/overlay.dart';
import 'package:appflowy_editor/src/service/context_menu/built_in_context_menu_item.dart';
import 'package:appflowy_editor/src/service/context_menu/context_menu.dart';
import 'package:flutter/material.dart' hide Overlay, OverlayEntry;

import 'package:appflowy_editor/src/render/selection/cursor_widget.dart';
import 'package:appflowy_editor/src/render/selection/selection_widget.dart';
import 'package:appflowy_editor/src/service/selection/selection_gesture.dart';
import 'package:provider/provider.dart';

class DesktopSelectionServiceWidget extends StatefulWidget {
  const DesktopSelectionServiceWidget({
    Key? key,
    this.cursorColor = const Color(0xFF00BCF0),
    this.selectionColor = const Color.fromARGB(53, 111, 201, 231),
    required this.child,
  }) : super(key: key);

  final Widget child;
  final Color cursorColor;
  final Color selectionColor;

  @override
  State<DesktopSelectionServiceWidget> createState() =>
      _DesktopSelectionServiceWidgetState();
}

class _DesktopSelectionServiceWidgetState
    extends State<DesktopSelectionServiceWidget>
    with WidgetsBindingObserver
    implements AppFlowySelectionService {
  final _cursorKey = GlobalKey(debugLabel: 'cursor');

  @override
  final List<Rect> selectionRects = [];
  final List<OverlayEntry> _selectionAreas = [];
  final List<OverlayEntry> _cursorAreas = [];
  final List<OverlayEntry> _contextMenuAreas = [];

  @override
  ValueNotifier<Selection?> currentSelection = ValueNotifier(null);

  @override
  List<Node> currentSelectedNodes = [];

  final List<SelectionGestureInterceptor> _interceptors = [];

  /// Pan
  Offset? _panStartOffset;
  double? _panStartScrollDy;

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
  List<Node> getNodesInSelection(Selection selection) {
    final start =
        selection.isBackward ? selection.start.path : selection.end.path;
    final end =
        selection.isBackward ? selection.end.path : selection.start.path;
    assert(start <= end);
    final startNode = editorState.document.nodeAtPath(start);
    final endNode = editorState.document.nodeAtPath(end);
    if (startNode != null && endNode != null) {
      final nodes = NodeIterator(
        document: editorState.document,
        startNode: startNode,
        endNode: endNode,
      ).toList();
      if (selection.isBackward) {
        return nodes;
      } else {
        return nodes.reversed.toList(growable: false);
      }
    }
    return [];
  }

  @override
  void updateSelection(Selection? selection) {
    if (currentSelection.value == selection) {
      return;
    }

    selectionRects.clear();
    _clearSelection();

    if (selection != null) {
      if (selection.isCollapsed) {
        // updates cursor area.
        Log.selection.debug('update cursor area, $selection');
        _updateCursorAreas(selection.start);
      } else {
        // updates selection area.
        Log.selection.debug('update cursor area, $selection');
        _updateSelectionAreas(selection);
      }
    }

    currentSelection.value = selection;
    editorState.selection = selection;
  }

  void _updateSelection() {
    final selection = editorState.selection;
    // TODO: why do we need to check this?
    if (currentSelection.value == selection &&
        editorState.selectionUpdateReason == SelectionUpdateReason.uiEvent &&
        editorState.selectionType != SelectionType.block) {
      return;
    }
    _scrollUpOrDownIfNeeded();
    currentSelection.value = selection;

    void updateSelection() {
      selectionRects.clear();
      _clearSelection();

      if (selection != null) {
        if (editorState.selectionType == SelectionType.block) {
          // updates selection area.
          Log.selection.debug('update block selection area, $selection');
          _updateBlockSelectionAreas(selection);
        } else if (selection.isCollapsed) {
          // updates cursor area.
          Log.selection.debug('update cursor area, $selection');
          _updateCursorAreas(selection.start);
        } else {
          // updates selection area.
          Log.selection.debug('update selection area, $selection');
          _updateSelectionAreas(selection);
        }
      }
    }

    if (editorState.selectionUpdateReason == SelectionUpdateReason.uiEvent) {
      updateSelection();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        updateSelection();
      });
    }
  }

  void _scrollUpOrDownIfNeeded() {
    final dy = editorState.service.scrollService?.dy;
    final selectNodes = currentSelectedNodes;
    final selection = currentSelection.value;
    if (dy == null || selection == null || selectNodes.isEmpty) {
      return;
    }

    final rect = selectNodes.last.rect;

    final size = MediaQuery.of(context).size.height;
    final topLimit = size * 0.3;
    final bottomLimit = size * 0.8;

    // TODO: It is necessary to calculate the relative speed
    //   according to the gap and move forward more gently.
    if (rect.top >= bottomLimit) {
      if (selection.isSingle) {
        editorState.service.scrollService?.scrollTo(dy + size * 0.2);
      } else if (selection.isBackward) {
        editorState.service.scrollService?.scrollTo(dy + 10.0);
      }
    } else if (rect.bottom <= topLimit) {
      if (selection.isForward) {
        editorState.service.scrollService?.scrollTo(dy - 10.0);
      }
    }
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

    // hide toolbar
    // editorState.service.toolbarService?.hide();

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
    final sortedNodes =
        editorState.document.root.children.toList(growable: false);
    return _getNodeInOffset(
      sortedNodes,
      offset,
      0,
      sortedNodes.length - 1,
    );
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
    final canTap = _interceptors.every(
      (element) => element.canTap?.call(details) ?? true,
    );
    if (!canTap) return;

    // clear old state.
    _panStartOffset = null;

    final position = getPositionInOffset(details.globalPosition);
    if (position == null) {
      return;
    }

    // updateSelection(selection);
    editorState.selection = Selection.collapsed(position);

    _showDebugLayerIfNeeded(offset: details.globalPosition);
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
    // selection.isCollapsedand and the selected node is TextNode.
    // try to select the word.
    final selection = currentSelection.value;
    if (selection == null ||
        (selection.isCollapsed == true &&
            currentSelectedNodes.first is TextNode)) {
      _onDoubleTapDown(details);
    }

    _showContextMenu(details);
  }

  void _onPanStart(DragStartDetails details) {
    clearSelection();

    _panStartOffset = details.globalPosition.translate(-3.0, 0);
    _panStartScrollDy = editorState.service.scrollService?.dy;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_panStartOffset == null || _panStartScrollDy == null) {
      return;
    }

    final panEndOffset = details.globalPosition;
    final dy = editorState.service.scrollService?.dy;
    final panStartOffset = dy == null
        ? _panStartOffset!
        : _panStartOffset!.translate(0, _panStartScrollDy! - dy);

    final first = getNodeInOffset(panStartOffset)?.selectable;
    final last = getNodeInOffset(panEndOffset)?.selectable;

    // compute the selection in range.
    if (first != null && last != null) {
      // Log.selection.debug('first = $first, last = $last');
      final start =
          first.getSelectionInRange(panStartOffset, panEndOffset).start;
      final end = last.getSelectionInRange(panStartOffset, panEndOffset).end;
      final selection = Selection(start: start, end: end);
      updateSelection(selection);
    }

    _showDebugLayerIfNeeded(offset: panEndOffset);

    editorState.service.scrollService?.startAutoScroll(
      details.globalPosition,
    );
  }

  void _onPanEnd(DragEndDetails details) {
    // do nothing
  }

  void _updateBlockSelectionAreas(Selection selection) {
    assert(editorState.selectionType == SelectionType.block);
    final nodes = getNodesInSelection(selection).normalized;

    currentSelectedNodes = nodes;

    final node = nodes.first;
    final rect = Offset.zero & node.rect.size;
    final overlay = OverlayEntry(
      builder: (context) => SelectionWidget(
        color: widget.selectionColor,
        layerLink: node.layerLink,
        rect: rect,
        decoration: BoxDecoration(
          color: widget.selectionColor,
          borderRadius: BorderRadius.circular(4.0),
        ),
      ),
    );
    _selectionAreas.add(overlay);

    Overlay.of(context)?.insertAll(_selectionAreas);
  }

  void _updateSelectionAreas(Selection selection) {
    final nodes = getNodesInSelection(selection);

    currentSelectedNodes = nodes;

    // TODO: need to be refactored.
    Offset? toolbarOffset;
    Alignment? alignment;
    LayerLink? layerLink;
    final editorOffset =
        editorState.renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final editorSize = editorState.renderBox?.size ?? Size.zero;

    final backwardNodes =
        selection.isBackward ? nodes : nodes.reversed.toList(growable: false);
    final normalizedSelection = selection.normalized;
    assert(normalizedSelection.isBackward);

    Log.selection.debug('update selection areas, $normalizedSelection');

    if (editorState.selectionType == SelectionType.block) {
      final node = backwardNodes.first;
      final rect = Offset.zero & node.rect.size;
      final overlay = OverlayEntry(
        builder: (context) => SelectionWidget(
          color: widget.selectionColor,
          layerLink: node.layerLink,
          rect: rect,
        ),
      );
      _selectionAreas.add(overlay);
    } else {
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

        const baseToolbarOffset = Offset(0, 35.0);
        final rects = selectable.getRectsInSelection(newSelection);
        for (final rect in rects) {
          final selectionRect = _transformRectToGlobal(selectable, rect);
          selectionRects.add(selectionRect);

          // TODO: Need to compute more precise location.
          if ((selectionRect.topLeft.dy - editorOffset.dy) <=
              baseToolbarOffset.dy) {
            if (selectionRect.topLeft.dx <=
                editorSize.width / 3.0 + editorOffset.dx) {
              toolbarOffset ??= rect.bottomLeft;
              alignment ??= Alignment.topLeft;
            } else if (selectionRect.topRight.dx >=
                editorSize.width * 2.0 / 3.0 + editorOffset.dx) {
              toolbarOffset ??= rect.bottomRight;
              alignment ??= Alignment.topRight;
            } else {
              toolbarOffset ??= rect.bottomCenter;
              alignment ??= Alignment.topCenter;
            }
          } else {
            if (selectionRect.topLeft.dx <=
                editorSize.width / 3.0 + editorOffset.dx) {
              toolbarOffset ??= rect.topLeft - baseToolbarOffset;
              alignment ??= Alignment.topLeft;
            } else if (selectionRect.topRight.dx >=
                editorSize.width * 2.0 / 3.0 + editorOffset.dx) {
              toolbarOffset ??= rect.topRight - baseToolbarOffset;
              alignment ??= Alignment.topRight;
            } else {
              toolbarOffset ??= rect.topCenter - baseToolbarOffset;
              alignment ??= Alignment.topCenter;
            }
          }

          layerLink ??= node.layerLink;

          final overlay = OverlayEntry(
            builder: (context) => SelectionWidget(
              color: widget.selectionColor,
              layerLink: node.layerLink,
              rect: rect,
            ),
          );
          _selectionAreas.add(overlay);
        }
      }
    }

    Overlay.of(context)?.insertAll(_selectionAreas);
  }

  void _updateCursorAreas(Position position) {
    final node = editorState.document.root.childAtPath(position.path);

    if (node == null) {
      assert(false);
      return;
    }

    currentSelectedNodes = [node];

    _showCursor(node, position);
  }

  void _showCursor(Node node, Position position) {
    final selectable = node.selectable;
    final cursorRect = selectable?.getCursorRectInPosition(position);
    if (selectable != null && cursorRect != null) {
      final cursorArea = OverlayEntry(
        builder: (context) => CursorWidget(
          key: _cursorKey,
          rect: cursorRect,
          color: widget.cursorColor,
          layerLink: node.layerLink,
          shouldBlink: selectable.shouldCursorBlink,
          cursorStyle: selectable.cursorStyle,
        ),
      );

      _cursorAreas.add(cursorArea);
      selectionRects.add(_transformRectToGlobal(selectable, cursorRect));
      Overlay.of(context)?.insertAll(_cursorAreas);

      _forceShowCursor();
    }
  }

  void _forceShowCursor() {
    _cursorKey.currentState?.unwrapOrNull<CursorWidgetState>()?.show();
  }

  void _showContextMenu(TapDownDetails details) {
    _clearContextMenu();

    // For now, only support the text node.
    if (!currentSelectedNodes.every((element) => element is TextNode)) {
      return;
    }

    final baseOffset =
        editorState.renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final offset = details.globalPosition + const Offset(10, 10) - baseOffset;
    final contextMenu = OverlayEntry(
      builder: (context) => ContextMenu(
        position: offset,
        editorState: editorState,
        items: builtInContextMenuItems,
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

  Rect _transformRectToGlobal(SelectableMixin selectable, Rect r) {
    final Offset topLeft = selectable.localToGlobal(Offset(r.left, r.top));
    return Rect.fromLTWH(topLeft.dx, topLeft.dy, r.width, r.height);
  }

  void _showDebugLayerIfNeeded({Offset? offset}) {
    // remove false to show debug overlay.
    // if (kDebugMode && false) {
    //   _debugOverlay?.remove();
    //   if (offset != null) {
    //     _debugOverlay = OverlayEntry(
    //       builder: (context) => Positioned.fromRect(
    //         rect: Rect.fromPoints(offset, offset.translate(20, 20)),
    //         child: Container(
    //           color: Colors.red.withOpacity(0.2),
    //         ),
    //       ),
    //     );
    //     Overlay.of(context)?.insert(_debugOverlay!);
    //   } else if (_panStartOffset != null) {
    //     _debugOverlay = OverlayEntry(
    //       builder: (context) => Positioned.fromRect(
    //         rect: Rect.fromPoints(
    //             _panStartOffset?.translate(
    //                   0,
    //                   -(editorState.service.scrollService!.dy -
    //                       _panStartScrollDy!),
    //                 ) ??
    //                 Offset.zero,
    //             offset ?? Offset.zero),
    //         child: Container(
    //           color: Colors.red.withOpacity(0.2),
    //         ),
    //       ),
    //     );
    //     Overlay.of(context)?.insert(_debugOverlay!);
    //   } else {
    //     _debugOverlay = null;
    //   }
    // }
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
