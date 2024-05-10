import 'package:flutter/material.dart' hide Overlay, OverlayEntry;
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/selection/mobile_selection_service.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/selection/shared.dart';
import 'package:appflowy_editor/src/flutter/overlay.dart';
import 'package:appflowy_editor/src/service/selection/selection_gesture.dart';

class DesktopSelectionServiceWidget extends StatefulWidget {
  const DesktopSelectionServiceWidget({
    super.key,
    this.cursorColor = const Color(0xFF00BCF0),
    this.selectionColor = const Color(0xFF00BCF0),
    this.contextMenuItems,
    required this.child,
  });

  final Widget child;
  final Color cursorColor;
  final Color selectionColor;
  final List<List<ContextMenuItem>>? contextMenuItems;

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
    final List<Node> sortedNodes = editorState.getVisibleNodes(
      context.read<EditorScrollController>(),
    );

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

    Selection? selection;
    if (HardwareKeyboard.instance.isShiftPressed && _panStartOffset != null) {
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

    final canPanStart = _interceptors
        .every((interceptor) => interceptor.canPanStart?.call(details) ?? true);

    if (!canPanStart) {
      return;
    }

    _panStartOffset = details.globalPosition.translate(-3.0, 0);
    _panStartScrollDy = editorState.service.scrollService?.dy;

    _panStartPosition = getNodeInOffset(_panStartOffset!)
        ?.selectable
        ?.getPositionInOffset(_panStartOffset!);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final canPanUpdate = _interceptors.every(
      (interceptor) => interceptor.canPanUpdate?.call(details) ?? true,
    );

    if (!canPanUpdate) {
      return;
    }

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
    final canPanEnd = _interceptors
        .every((interceptor) => interceptor.canPanEnd?.call(details) ?? true);

    if (!canPanEnd) {
      return;
    }

    _panStartPosition = null;

    editorState.service.scrollService?.stopAutoScroll();
  }

  void _updateSelection() {
    final selection = editorState.selectionNotifier.value;
    if (selection == null) {
      clearSelection();
    }
  }

  void _showContextMenu(TapDownDetails details) {
    _clearContextMenu();

    // Don't trigger the context menu if there are no items
    if (widget.contextMenuItems == null || widget.contextMenuItems!.isEmpty) {
      return;
    }

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
        items: widget.contextMenuItems!,
        onPressed: () => _clearContextMenu(),
      ),
    );

    _contextMenuAreas.add(contextMenu);
    Overlay.of(context, rootOverlay: true)?.insert(contextMenu);
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
