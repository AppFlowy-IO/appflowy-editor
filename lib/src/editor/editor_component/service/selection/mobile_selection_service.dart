import 'dart:async';
import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/selection/mobile_magnifier.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/selection/shared.dart';
import 'package:appflowy_editor/src/render/selection/mobile_basic_handle.dart';
import 'package:appflowy_editor/src/render/selection/mobile_collapsed_handle.dart';
import 'package:appflowy_editor/src/render/selection/mobile_selection_handle.dart';
import 'package:appflowy_editor/src/service/selection/mobile_selection_gesture.dart';
import 'package:flutter/material.dart' hide Overlay, OverlayEntry;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

/// only used in mobile
///
/// this will notify the developers when the selection is not collapsed.
StreamController<int> appFlowyEditorOnTapSelectionArea =
    StreamController<int>.broadcast();

enum MobileSelectionDragMode {
  none,
  leftSelectionHandle,
  rightSelectionHandle,
  cursor;
}

enum MobileSelectionHandlerType {
  leftHandle,
  rightHandle,
  cursorHandle,
}

// the value type is MobileSelectionDragMode
const String selectionDragModeKey = 'selection_drag_mode';
bool disableMagnifier = false;

class MobileSelectionServiceWidget extends StatefulWidget {
  const MobileSelectionServiceWidget({
    super.key,
    this.cursorColor = const Color(0xFF00BCF0),
    this.selectionColor = const Color.fromARGB(53, 111, 201, 231),
    this.showMagnifier = true,
    this.magnifierSize = const Size(72, 48),
    required this.child,
  });

  final Widget child;
  final Color cursorColor;
  final Color selectionColor;

  /// Show the magnifier or not.
  ///
  /// only works on iOS or Android.
  final bool showMagnifier;

  final Size magnifierSize;

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

  @override
  ValueNotifier<Selection?> currentSelection = ValueNotifier(null);

  @override
  List<Node> currentSelectedNodes = [];

  final List<SelectionGestureInterceptor> _interceptors = [];
  final ValueNotifier<Offset?> _lastPanOffset = ValueNotifier(null);

  // the selection from editorState will be updated directly, but the cursor
  // or selection area depends on the layout of the text, so we need to update
  // the selection after the layout.
  final PropertyValueNotifier<Selection?> selectionNotifierAfterLayout =
      PropertyValueNotifier<Selection?>(null);

  /// Pan
  Offset? _panStartOffset;
  double? _panStartScrollDy;
  Selection? _panStartSelection;

  MobileSelectionDragMode dragMode = MobileSelectionDragMode.none;

  bool updateSelectionByTapUp = false;

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
    selectionNotifierAfterLayout.dispose();
    editorState.selectionNotifier.removeListener(_updateSelection);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MobileSelectionGestureDetector(
      onTapUp: _onTapUp,
      onDoubleTapUp: _onDoubleTapUp,
      onTripleTapUp: _onTripleTapUp,
      onLongPressStart: _onLongPressStart,
      child: Stack(
        children: [
          widget.child,

          // magnifier for zoom in the text.
          if (widget.showMagnifier) _buildMagnifier(),

          // the handles for expanding the selection area.
          _buildLeftHandle(),
          _buildRightHandle(),
          _buildCollapsedHandle(),
        ],
      ),
    );
  }

  Widget _buildMagnifier() {
    return ValueListenableBuilder(
      valueListenable: _lastPanOffset,
      builder: (_, offset, __) {
        if (offset == null || disableMagnifier) {
          return const SizedBox.shrink();
        }
        final renderBox = context.findRenderObject() as RenderBox;
        final local = renderBox.globalToLocal(offset);
        return MobileMagnifier(
          size: widget.magnifierSize,
          offset: local,
        );
      },
    );
  }

  Widget _buildCollapsedHandle() {
    return ValueListenableBuilder(
      valueListenable: selectionNotifierAfterLayout,
      builder: (context, selection, _) {
        if (selection == null ||
            !selection.isCollapsed ||
            editorState.selectionUpdateReason !=
                SelectionUpdateReason.uiEvent) {
          return const SizedBox.shrink();
        }

        if (selection.isCollapsed &&
            [
              MobileSelectionDragMode.leftSelectionHandle,
              MobileSelectionDragMode.rightSelectionHandle,
            ].contains(dragMode)) {
          return const SizedBox.shrink();
        }

        selection = selection.normalized;

        final node = editorState.getNodeAtPath(selection.start.path);
        final selectable = node?.selectable;
        var rect = selectable?.getCursorRectInPosition(
          selection.start,
          shiftWithBaseOffset: true,
        );

        if (node == null || rect == null) {
          return const SizedBox.shrink();
        }

        final editorStyle = editorState.editorStyle;
        return MobileCollapsedHandle(
          layerLink: node.layerLink,
          rect: rect,
          handleColor: editorStyle.dragHandleColor,
          handleWidth: editorStyle.mobileDragHandleWidth,
          handleBallWidth: editorStyle.mobileDragHandleBallSize.width,
          enableHapticFeedbackOnAndroid:
              editorStyle.enableHapticFeedbackOnAndroid,
        );
      },
    );
  }

  Widget _buildLeftHandle() {
    return _buildHandle(HandleType.left);
  }

  Widget _buildRightHandle() {
    return _buildHandle(HandleType.right);
  }

  Widget _buildHandle(HandleType handleType) {
    if (![HandleType.left, HandleType.right].contains(handleType)) {
      throw ArgumentError('showLeftHandle and showRightHandle cannot be same.');
    }

    return ValueListenableBuilder(
      valueListenable: selectionNotifierAfterLayout,
      builder: (context, selection, _) {
        if (selection == null) {
          return const SizedBox.shrink();
        }

        if (selection.isCollapsed &&
            [
              MobileSelectionDragMode.none,
              MobileSelectionDragMode.cursor,
            ].contains(dragMode)) {
          return const SizedBox.shrink();
        }

        final isCollapsedWhenDraggingHandle = selection.isCollapsed &&
            [
              MobileSelectionDragMode.leftSelectionHandle,
              MobileSelectionDragMode.rightSelectionHandle,
            ].contains(dragMode);

        selection = selection.normalized;

        final node = editorState.getNodeAtPath(
          handleType == HandleType.left
              ? selection.start.path
              : selection.end.path,
        );
        final selectable = node?.selectable;

        // get the cursor rect when the selection is collapsed.
        final rects = isCollapsedWhenDraggingHandle
            ? [
                selectable?.getCursorRectInPosition(
                      selection.start,
                      shiftWithBaseOffset: true,
                    ) ??
                    Rect.zero,
              ]
            : selectable?.getRectsInSelection(
                selection,
                shiftWithBaseOffset: true,
              );

        if (node == null || rects == null || rects.isEmpty) {
          return const SizedBox.shrink();
        }

        final editorStyle = editorState.editorStyle;
        return MobileSelectionHandle(
          layerLink: node.layerLink,
          rect: handleType == HandleType.left ? rects.first : rects.last,
          handleType: handleType,
          handleColor: isCollapsedWhenDraggingHandle
              ? Colors.transparent
              : editorStyle.dragHandleColor,
          handleWidth: editorStyle.mobileDragHandleWidth,
          handleBallWidth: editorStyle.mobileDragHandleBallSize.width,
          enableHapticFeedbackOnAndroid:
              editorStyle.enableHapticFeedbackOnAndroid,
        );
      },
    );
  }

  @override
  void updateSelection(Selection? selection) {
    if (currentSelection.value == selection) {
      return;
    }

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
      extraInfo: {
        selectionDragModeKey: dragMode,
        selectionExtraInfoDoNotAttachTextService:
            dragMode == MobileSelectionDragMode.cursor,
      },
    );
  }

  @override
  void clearSelection() {
    currentSelectedNodes = [];
    currentSelection.value = null;
    _lastPanOffset.value = null;

    _clearSelection();
  }

  @override
  void clearCursor() {
    _clearSelection();
  }

  void _clearSelection() {
    selectionRects.clear();
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
  void registerGestureInterceptor(SelectionGestureInterceptor interceptor) {
    _interceptors.add(interceptor);
  }

  @override
  void unregisterGestureInterceptor(String key) {
    _interceptors.removeWhere((element) => element.key == key);
  }

  void _updateSelection() {
    final selection = editorState.selection;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      selectionNotifierAfterLayout.value = selection;
    });

    if (currentSelection.value != selection) {
      clearSelection();
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
    final offset = details.globalPosition;
    if (_isClickOnSelectionArea(offset)) {
      appFlowyEditorOnTapSelectionArea.add(0);
      return;
    }

    clearSelection();

    // clear old state.
    _panStartOffset = null;

    final position = getPositionInOffset(offset);
    if (position == null) {
      return;
    }

    editorState.updateSelectionWithReason(
      Selection.collapsed(position),
      reason: SelectionUpdateReason.uiEvent,
      extraInfo: null,
    );
  }

  void _onDoubleTapUp(TapUpDetails details) {
    final offset = details.globalPosition;
    if (_isClickOnSelectionArea(offset)) {
      appFlowyEditorOnTapSelectionArea.add(0);
      return;
    }
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

  @override
  Selection? onPanStart(
    DragStartDetails details,
    MobileSelectionDragMode mode,
  ) {
    _panStartOffset = details.globalPosition.translate(-3.0, 0);
    _panStartScrollDy = editorState.service.scrollService?.dy;

    final selection = editorState.selection;
    _panStartSelection = selection;

    dragMode = mode;

    return selection;
  }

  @override
  Selection? onPanUpdate(
    DragUpdateDetails details,
    MobileSelectionDragMode mode,
  ) {
    if (_panStartOffset == null || _panStartScrollDy == null) {
      return null;
    }

    // only support selection mode now.
    final selection = editorState.selection;
    if (selection == null || dragMode == MobileSelectionDragMode.none) {
      return null;
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

    Selection? newSelection;

    if (end != null) {
      if (dragMode == MobileSelectionDragMode.leftSelectionHandle) {
        newSelection = Selection(
          start: _panStartSelection!.normalized.end,
          end: end,
        ).normalized;
      } else if (dragMode == MobileSelectionDragMode.rightSelectionHandle) {
        newSelection = Selection(
          start: _panStartSelection!.normalized.start,
          end: end,
        ).normalized;
      } else if (dragMode == MobileSelectionDragMode.cursor) {
        newSelection = Selection.collapsed(end);
      }
      _lastPanOffset.value = panEndOffset;
    }

    if (newSelection != null) {
      updateSelection(newSelection);
    }

    return newSelection;
  }

  @override
  void onPanEnd(DragEndDetails details, MobileSelectionDragMode mode) {
    // do nothing
    _lastPanOffset.value = null;

    // clear the status
    dragMode = MobileSelectionDragMode.none;
    editorState.updateSelectionWithReason(
      editorState.selection,
      reason: SelectionUpdateReason.uiEvent,
      extraInfo: {
        selectionExtraInfoDoNotAttachTextService: false,
      },
    );
  }

  void _onLongPressStart(LongPressStartDetails details) {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }

    // on Android, long press to select a word.
    final offset = details.globalPosition;
    if (_isClickOnSelectionArea(offset)) {
      appFlowyEditorOnTapSelectionArea.add(0);
      return;
    }
    final node = getNodeInOffset(offset);
    final selection = node?.selectable?.getWordBoundaryInOffset(offset);
    if (selection == null) {
      clearSelection();
      return;
    }

    if (editorState.editorStyle.enableHapticFeedbackOnAndroid) {
      HapticFeedback.mediumImpact();
    }

    updateSelection(selection);
  }

  // delete this function in the future.
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
      for (final rect in rects) {
        final selectionRect = selectable.transformRectToGlobal(
          rect,
          shiftWithBaseOffset: true,
        );
        selectionRects.add(selectionRect);
      }
    }
  }

  bool _isClickOnSelectionArea(Offset point) {
    for (final rect in selectionRects) {
      if (rect.contains(point)) {
        return true;
      }
    }
    return false;
  }
}
