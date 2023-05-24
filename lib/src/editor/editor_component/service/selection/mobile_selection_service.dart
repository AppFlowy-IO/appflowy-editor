import 'dart:ui';
import 'dart:math' as math;
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/flutter/overlay.dart';
import 'package:appflowy_editor/src/service/context_menu/built_in_context_menu_item.dart';
import 'package:appflowy_editor/src/service/context_menu/context_menu.dart';
import 'package:flutter/material.dart' hide Overlay, OverlayEntry;

import 'package:appflowy_editor/src/render/selection/cursor_widget.dart';
import 'package:appflowy_editor/src/render/selection/selection_widget.dart';
import 'package:appflowy_editor/src/service/selection/selection_gesture.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class MobileSelectionServiceWidget extends StatefulWidget {
  const MobileSelectionServiceWidget({
    Key? key,
    this.cursorColor = const Color(0xFF00BCF0),
    this.selectionColor = const Color.fromARGB(53, 111, 201, 231),
    required this.child,
  }) : super(key: key);

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
    editorState.updateCursorSelection(selection, CursorUpdateReason.uiEvent);
  }

  void _updateSelection() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      selectionRects.clear();
      _clearSelection();

      final selection = editorState.selection;

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
    });
  }

  RevealedOffset _getOffsetToRevealCaret(Rect rect) {
    if (!editorState.service.scrollService!.implecet) {
      return RevealedOffset(
        offset: editorState.service.scrollService!.offset,
        rect: rect,
      );
    }

    final Size editableSize = editorState.renderBox!.size;
    final double additionalOffset;
    final Offset unitOffset;

    // The caret is vertically centered within the line. Expand the caret's
    // height so that it spans the line because we're going to ensure that the
    // entire expanded caret is scrolled into view.
    final Rect expandedRect = Rect.fromCenter(
      center: rect.center,
      width: rect.width,
      height: math.max(rect.height, 20),
    );

    additionalOffset = expandedRect.height >= editableSize.height
        ? editableSize.height / 2 - expandedRect.center.dy
        : clampDouble(
            0.0,
            expandedRect.bottom - editableSize.height,
            expandedRect.top,
          );
    unitOffset = const Offset(0, 1);

    // No overscrolling when encountering tall fonts/scripts that extend past
    // the ascent.
    final double targetOffset = clampDouble(
      additionalOffset + rect.top + 200,
      editorState.service.scrollService!.minScrollExtent,
      editorState.service.scrollService!.maxScrollExtent,
    );

    final double offsetDelta = targetOffset;
    return RevealedOffset(
      rect: rect.shift(unitOffset * offsetDelta),
      offset: targetOffset,
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
    final canTap =
        _interceptors.every((element) => element.canTap?.call(details) ?? true);
    if (!canTap) return;

    editorState.service.scrollService?.stopAutoScroll();

    final position = getPositionInOffset(details.globalPosition);
    if (position == null) {
      return;
    }
    final selection = Selection.collapsed(position);
    updateSelection(selection);

    _showDebugLayerIfNeeded(offset: details.globalPosition);

    editorState.service.scrollService?.startAutoScroll(
      details.globalPosition,
      edgeOffset: 300,
      direction: AxisDirection.up,
    );
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
      Log.selection
          .debug("reveal:${_getOffsetToRevealCaret(cursorRect).offset}");
      editorState.service.scrollService?.scrollController.animateTo(
        _getOffsetToRevealCaret(cursorRect).offset,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeIn,
      );

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

  final List<SelectionGestureInterceptor> _interceptors = [];
  @override
  void registerGestureInterceptor(SelectionGestureInterceptor interceptor) {
    _interceptors.add(interceptor);
  }

  @override
  void unregisterGestureInterceptor(String key) {
    _interceptors.removeWhere((element) => element.key == key);
  }
}
