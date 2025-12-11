import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/selection/mobile_selection_service.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/selection/shared.dart';
import 'package:appflowy_editor/src/service/selection/selection_gesture.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class DesktopSelectionServiceWidget extends StatefulWidget {
  const DesktopSelectionServiceWidget({
    super.key,
    this.cursorColor = const Color(0xFF00BCF0),
    this.selectionColor = const Color(0xFF00BCF0),
    this.contextMenuBuilder,
    required this.child,
    this.dropTargetStyle = const AppFlowyDropTargetStyle(),
  });

  final Widget child;
  final Color cursorColor;
  final Color selectionColor;
  final ContextMenuWidgetBuilder? contextMenuBuilder;
  final AppFlowyDropTargetStyle dropTargetStyle;

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

  bool _isDraggingSelection = false;
  Offset? _lastPanOffset;

  OverlayEntry? _dropTargetEntry;

  late EditorState editorState = Provider.of<EditorState>(
    context,
    listen: false,
  );

  _ContextMenuKeyboardInterceptor? _keyboardInterceptor;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    editorState.selectionNotifier.addListener(_updateSelection);
    editorState.addScrollViewScrolledListener(_handleAutoScrollWhileDragging);
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
    editorState.removeScrollViewScrolledListener(
      _handleAutoScrollWhileDragging,
    );
    currentSelection.dispose();
    removeDropTarget();
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

  @override
  void clearSelection() {
    // currentSelectedNodes = [];
    _resetPanState();
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

  void _resetPanState() {
    _isDraggingSelection = false;
    _panStartOffset = null;
    _panStartScrollDy = null;
    _panStartPosition = null;
    _lastPanOffset = null;
  }

  void _clearContextMenu() {
    if (_contextMenuAreas.isEmpty) {
      return;
    }

    _contextMenuAreas
      ..forEach((overlay) => overlay.remove())
      ..clear();

    if (_keyboardInterceptor != null) {
      editorState.service.keyboardService
          ?.unregisterInterceptor(_keyboardInterceptor!);
      _keyboardInterceptor = null;
    }

    editorState.service.keyboardService?.enableShortcuts();
    editorState.service.keyboardService?.enable();

    final selection = editorState.selectionNotifier.value;
    if (selection != null) {
      editorState.updateSelectionWithReason(
        null,
        reason: SelectionUpdateReason.uiEvent,
      );
      editorState.updateSelectionWithReason(
        selection,
        reason: SelectionUpdateReason.uiEvent,
      );
    }
  }

  @override
  Node? getNodeInOffset(Offset offset) {
    final List<Node> sortedNodes = editorState.getVisibleNodes(
      context.read<EditorScrollController>(),
    );

    if (sortedNodes.isEmpty) {
      return null;
    }

    return editorState.getNodeInOffset(
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

  void _onTapDown(TapDownDetails details) {
    _clearContextMenu();

    final canTap = _interceptors.every(
      (element) => element.canTap?.call(details) ?? true,
    );
    if (!canTap) {
      return updateSelection(null);
    }

    final offset = details.globalPosition;
    final node = getNodeInOffset(offset);
    final selectable = node?.selectable;
    if (selectable == null) {
      // Clear old start offset
      _panStartOffset = null;
      return clearSelection();
    }

    final position = selectable.getPositionInOffset(offset);
    final Selection? selection;

    if (HardwareKeyboard.instance.isShiftPressed && _panStartPosition != null) {
      selection = Selection(start: _panStartPosition!, end: position);
    } else {
      selection = selectable.cursorStyle == CursorStyle.verticalLine
          ? Selection.collapsed(position)
          : Selection(start: selectable.start(), end: selectable.end());

      // Reset old start offset
      _panStartPosition = position;
    }

    updateSelection(selection);
  }

  void _onDoubleTapDown(TapDownDetails details) {
    final canDoubleTap = _interceptors.every(
      (interceptor) => interceptor.canDoubleTap?.call(details) ?? true,
    );

    if (!canDoubleTap) {
      return updateSelection(null);
    }

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
    final canTripleTap = _interceptors.every(
      (interceptor) => interceptor.canTripleTap?.call(details) ?? true,
    );

    if (!canTripleTap) {
      return updateSelection(null);
    }
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
    final offset = details.globalPosition;
    final selection = editorState.selectionNotifier.value;
    final node = getNodeInOffset(offset);
    final selectable = node?.selectable;

    if (selectable == null) {
      clearSelection();
      return;
    }

    final position = selectable.getPositionInOffset(offset);
    final Selection? newSelection;

    // cases
    // 1. if the selection is null, then select the current position as a collapsed selection
    // 2. if the selection is collapsed, then keep it without changes
    // 3. if the selection is not collapsed, then check if tap is within a selected node
    // 4. if tap is within the selected nodes, then keep current selection
    // 5. if tap is outside the selected nodes, then create a collapsed selection at tap point

    if (selection == null) {
      newSelection = Selection.collapsed(position);
    } else if (selection.isCollapsed) {
      newSelection = selection;
    } else {
      final selectedNodes = editorState.getNodesInSelection(selection);
      final isTapInSelectedNode = selectedNodes.any((n) => n == node);

      if (isTapInSelectedNode) {
        newSelection = selection;
      } else {
        newSelection = Selection.collapsed(position);
      }
    }

    editorState.updateSelectionWithReason(
      newSelection,
      extraInfo: {
        selectionExtraInfoDisableToolbar: true,
      },
    );

    _showContextMenu(details);
  }

  void _onPanStart(DragStartDetails details) {
    clearSelection();

    final canPanStart = _interceptors.every(
      (interceptor) => interceptor.canPanStart?.call(details) ?? true,
    );

    if (!canPanStart) {
      return;
    }

    _panStartOffset = details.globalPosition;
    _panStartScrollDy = editorState.service.scrollService?.dy;

    _panStartPosition = getNodeInOffset(_panStartOffset!)
        ?.selectable
        ?.getPositionInOffset(_panStartOffset!);
    if (_panStartPosition == null) {
      _resetPanState();
      return;
    }

    _lastPanOffset = _panStartOffset;
    _isDraggingSelection = true;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final canPanUpdate = _interceptors.every(
      (interceptor) => interceptor.canPanUpdate?.call(details) ?? true,
    );

    if (!canPanUpdate) {
      return;
    }

    if (!_isDraggingSelection ||
        _panStartOffset == null ||
        _panStartPosition == null) {
      return;
    }

    _lastPanOffset = details.globalPosition;
    _updateSelectionDuringDrag(_lastPanOffset!);

    editorState.service.scrollService?.startAutoScroll(
      _lastPanOffset!,
      edgeOffset: 200,
      duration: const Duration(milliseconds: 2),
    );
  }

  void _onPanEnd(DragEndDetails details) {
    final canPanEnd = _interceptors
        .every((interceptor) => interceptor.canPanEnd?.call(details) ?? true);

    if (!canPanEnd) {
      return;
    }

    editorState.service.scrollService?.stopAutoScroll();
    _resetPanState();
  }

  void _updateSelectionDuringDrag(Offset panEndOffset) {
    if (!_isDraggingSelection ||
        _panStartPosition == null ||
        _panStartOffset == null) {
      return;
    }

    final double? currentDy = editorState.service.scrollService?.dy;
    final Offset panStartOffset = currentDy == null || _panStartScrollDy == null
        ? _panStartOffset!
        : _panStartOffset!.translate(
            0,
            _panStartScrollDy! - currentDy,
          );

    final selectable = getNodeInOffset(panEndOffset)?.selectable;
    if (selectable == null) {
      return;
    }

    final Selection selection = Selection(
      start: _panStartPosition!,
      end: selectable
          .getSelectionInRange(
            panStartOffset,
            panEndOffset,
          )
          .end,
    );

    if (selection != currentSelection.value) {
      updateSelection(selection);
    }
  }

  void _handleAutoScrollWhileDragging() {
    if (!mounted || !_isDraggingSelection || _lastPanOffset == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !_isDraggingSelection ||
          _lastPanOffset == null ||
          _panStartOffset == null ||
          _panStartPosition == null) {
        return;
      }

      _updateSelectionDuringDrag(_lastPanOffset!);
      editorState.autoScroller?.continueToAutoScroll();
    });
  }

  void _updateSelection() {
    final selection = editorState.selectionNotifier.value;
    if (selection == null) {
      clearSelection();
    }
  }

  void _showContextMenu(TapDownDetails details) {
    _clearContextMenu();

    // Don't trigger the context menu if the builder is null
    if (widget.contextMenuBuilder == null) {
      return;
    }

    // only shows around the selection area.
    if (selectionRects.isEmpty) {
      return;
    }

    // For now, only support the text node.
    if (!currentSelectedNodes.every((element) => element.delta != null)) {
      return;
    }

    final mask = OverlayEntry(
      builder: (_) => Listener(
        onPointerDown: (_) => _clearContextMenu(),
        child: Container(
          color: Colors.transparent,
        ),
      ),
    );
    _contextMenuAreas.add(mask);
    Overlay.of(context, rootOverlay: true).insert(mask);

    final baseOffset =
        editorState.renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final offset = details.localPosition + const Offset(10, 10) + baseOffset;
    final contextMenu = OverlayEntry(
      builder: (_) =>
          widget.contextMenuBuilder?.call(
            context,
            offset,
            editorState,
            () => _clearContextMenu(),
          ) ??
          SizedBox.shrink(),
    );

    _contextMenuAreas.add(contextMenu);
    Overlay.of(context, rootOverlay: true).insert(contextMenu);

    _keyboardInterceptor = _ContextMenuKeyboardInterceptor();
    editorState.service.keyboardService
        ?.registerInterceptor(_keyboardInterceptor!);

    editorState.service.keyboardService?.disableShortcuts();
    editorState.service.keyboardService?.disable();
  }

  @override
  void registerGestureInterceptor(SelectionGestureInterceptor interceptor) {
    _interceptors.add(interceptor);
  }

  @override
  void unregisterGestureInterceptor(String key) {
    _interceptors.removeWhere((element) => element.key == key);
  }

  @override
  void removeDropTarget() {
    _dropTargetEntry?.remove();
    _dropTargetEntry = null;
  }

  @override
  void renderDropTargetForOffset(
    Offset offset, {
    DragAreaBuilder? builder,
    DragTargetNodeInterceptor? interceptor,
  }) {
    removeDropTarget();

    Node? node = getNodeInOffset(offset);
    if (node == null) {
      return;
    }

    if (interceptor != null) {
      node = interceptor(context, node);
    }

    final selectable = node.selectable;
    if (selectable == null) {
      return;
    }

    final blockRect = selectable.getBlockRect();
    final startOffset = blockRect.topLeft;
    final endOffset = blockRect.bottomLeft;

    final renderBox = selectable.context.findRenderObject() as RenderBox;
    final globalStartOffset = renderBox.localToGlobal(startOffset);
    final globalEndOffset = renderBox.localToGlobal(endOffset);

    final topDistance = (globalStartOffset - offset).distanceSquared;
    final bottomDistance = (globalEndOffset - offset).distanceSquared;

    final isCloserToStart = topDistance < bottomDistance;

    _dropTargetEntry = OverlayEntry(
      builder: (context) {
        if (builder != null && node != null) {
          return builder(
            context,
            DragAreaBuilderData(
              targetNode: node,
              dragOffset: offset,
            ),
          );
        }

        final overlayRenderBox =
            Overlay.of(context).context.findRenderObject() as RenderBox;
        final editorRenderBox =
            selectable.context.findRenderObject() as RenderBox;

        final editorOffset = editorRenderBox.localToGlobal(
          Offset.zero,
          ancestor: overlayRenderBox,
        );

        final indicatorTop =
            (isCloserToStart ? startOffset.dy : endOffset.dy) + editorOffset.dy;

        final width = blockRect.topRight.dx - startOffset.dx;
        return Positioned(
          top: indicatorTop,
          left: startOffset.dx + editorOffset.dx,
          child: Container(
            height: widget.dropTargetStyle.height,
            width: width,
            margin: widget.dropTargetStyle.margin,
            constraints: widget.dropTargetStyle.constraints,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(widget.dropTargetStyle.borderRadius),
              color: widget.dropTargetStyle.color,
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_dropTargetEntry!);
  }

  @override
  DropTargetRenderData? getDropTargetRenderData(
    Offset offset, {
    DragTargetNodeInterceptor? interceptor,
  }) {
    Node? node = getNodeInOffset(offset);

    if (node == null) {
      return null;
    }

    if (interceptor != null) {
      node = interceptor(context, node);
    }

    final selectable = node.selectable;
    if (selectable == null) {
      return null;
    }

    final blockRect = selectable.getBlockRect();
    final startRect = blockRect.topLeft;
    final endRect = blockRect.bottomLeft;

    final renderBox = selectable.context.findRenderObject() as RenderBox;
    final globalStartRect = renderBox.localToGlobal(startRect);
    final globalEndRect = renderBox.localToGlobal(endRect);

    final topDistance = (globalStartRect - offset).distanceSquared;
    final bottomDistance = (globalEndRect - offset).distanceSquared;

    final isCloserToStart = topDistance < bottomDistance;

    final dropPath = isCloserToStart ? node.path : node.path.next;

    return DropTargetRenderData(
      dropPath: dropPath,
      cursorNode: node,
    );
  }
}

class _ContextMenuKeyboardInterceptor
    extends AppFlowyKeyboardServiceInterceptor {
  @override
  Future<bool> interceptInsert(
    TextEditingDeltaInsertion insertion,
    EditorState editorState,
    List<CharacterShortcutEvent> characterShortcutEvents,
  ) async {
    return true;
  }

  @override
  Future<bool> interceptDelete(
    TextEditingDeltaDeletion deletion,
    EditorState editorState,
  ) async {
    return true;
  }

  @override
  Future<bool> interceptReplace(
    TextEditingDeltaReplacement replacement,
    EditorState editorState,
    List<CharacterShortcutEvent> characterShortcutEvents,
  ) async {
    return true;
  }

  @override
  Future<bool> interceptNonTextUpdate(
    TextEditingDeltaNonTextUpdate nonTextUpdate,
    EditorState editorState,
    List<CharacterShortcutEvent> characterShortcutEvents,
  ) async {
    return true;
  }

  @override
  Future<bool> interceptPerformAction(
    TextInputAction action,
    EditorState editorState,
  ) async {
    return true;
  }
}
