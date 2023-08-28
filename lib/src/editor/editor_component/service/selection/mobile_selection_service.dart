import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/flutter/overlay.dart';
import 'package:appflowy_editor/src/render/selection/mobile_selection_widget.dart';
import 'package:appflowy_editor/src/service/selection/mobile_selection_gesture_detector.dart';
import 'package:flutter/material.dart' hide Overlay, OverlayEntry;

import 'package:appflowy_editor/src/render/selection/cursor_widget.dart';
import 'package:provider/provider.dart';

class MobileSelectionServiceWidget extends StatefulWidget {
  const MobileSelectionServiceWidget({
    super.key,
    this.cursorColor = const Color(0xFF00BCF0),
    this.selectionColor = const Color.fromARGB(53, 111, 201, 231),
    this.selectionHandleColor = const Color(0xFF00BCF0),
    required this.child,
  });

  final Widget child;
  final Color cursorColor;
  final Color selectionColor;
  final Color selectionHandleColor;

  @override
  State<MobileSelectionServiceWidget> createState() =>
      _MobileSelectionServiceWidgetState();
}

class _MobileSelectionServiceWidgetState
    extends State<MobileSelectionServiceWidget>
    with WidgetsBindingObserver
    implements AppFlowySelectionService {
  final _cursorKey = GlobalKey<CursorWidgetState>(debugLabel: 'mobile_cursor');

  // Due to we need the ability to remove all the selection, these variables are used to record the selection [OverlayEntry] before we remove them.
  final List<OverlayEntry> _selectionOverlayEntries = [];
  OverlayEntry? _cursorOverlayEntry;

  @override
  final List<Rect> selectionRects = [];

  @override
  ValueNotifier<Selection?> currentSelection = ValueNotifier(null);

  @override
  List<Node> currentSelectedNodes = [];

  final List<SelectionGestureInterceptor> _interceptors = [];

  /// The global position when the user [onTap]
  Offset? _tapUpOffset;

  /// The global position when the user [onDoubleTap]
  Offset? _doubleTapDownOffset;

  /// The local Rect for building the cursor
  Rect? _cursorRect;

  /// The local Rect for building the left handler
  Rect? _leftHandlerRect;

  /// The local Rect for building the right handler
  Rect? _rightHandlerRect;

  late EditorState editorState = Provider.of<EditorState>(
    context,
    listen: false,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    editorState.selectionNotifier.addListener(_updateSelectionLayers);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Rebuild the selection when the metrics change.
    // For example, when users rotate the device from vertical to horizontal, we need to rebuild the new selection layers on horizontal direction.
    if (editorState.selection != null) {
      Debounce.debounce(
        'didChangeMetrics - update selection ',
        const Duration(milliseconds: 100),
        () => _updateSelectionLayers(),
      );
    }
  }

  @override
  void dispose() {
    clearSelection();
    WidgetsBinding.instance.removeObserver(this);
    editorState.selectionNotifier.removeListener(_updateSelectionLayers);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // User's gestures will lead to the change of [editorState.selection]. By listening to the change of [editorState.selection], we rebuild/insert the selection layers(like cirsor and selection with handles) .
    return MobileSelectionGestureDetector(
      onTapUp: _onTapUp,
      onTap: _onTap,
      onDoubleTapDown: _onDoubleTapDown,
      onDoubleTap: _onDoubleTap,
      onLongPressMoveUpdate: _onLongPressMoveUpdate,
      child: widget.child,
    );
  }

  @override
  void updateSelection(Selection? selection) {
    Log.selection.debug('updateSelection');
  }

  @override

  /// Remove all the overlay entries on the page
  void clearSelection() {
    Log.selection.debug('clearSelection');
    clearCursor();
    // clear selection areas
    _selectionOverlayEntries
      ..forEach((overlay) => overlay.remove())
      ..clear();

    // clear all the rects of the selection
    selectionRects.clear();
  }

  @override

  /// Remove the cursor overlay entry on the page
  void clearCursor() {
    Log.selection.debug('clearCursor');
    if (_cursorOverlayEntry != null) {
      _cursorOverlayEntry!.remove();
      _cursorOverlayEntry = null;
    }
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

  @override
  void registerGestureInterceptor(SelectionGestureInterceptor interceptor) {
    _interceptors.add(interceptor);
  }

  @override
  void unregisterGestureInterceptor(String key) {
    _interceptors.removeWhere((element) => element.key == key);
  }

  /// Update the selection layers UI(cursors and selection hanlders)
  /// base on different type of selection in editorState.
  void _updateSelectionLayers() {
    final selection = editorState.selection;
    clearSelection();

    void renderSelectionLayers() {
      if (selection == null) return;
      if (selection.isCollapsed) {
        Log.selection.debug('update cursor area, $selection');

        _updateCursor(selection.start);
      } else {
        // updates selection area.
        Log.selection.debug('update selection area, $selection');
        _updateSelectionAreas(selection);
      }
    }

    if (editorState.selectionUpdateReason == SelectionUpdateReason.uiEvent) {
      renderSelectionLayers();
    } else {
      WidgetsBinding.instance
          .addPostFrameCallback((timeStamp) => renderSelectionLayers());
    }
  }

  /// Render selection with handles
  void _updateSelectionAreas(Selection selection) {
    final nodes = editorState.getNodesInSelection(selection);
    Log.selection.debug(' _updateSelectionAreas nodes: $nodes');

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

      // Get all the rects from selection
      final selectionRects = selectable.getRectsInSelection(newSelection);
      for (final selectionRect in selectionRects) {
        // Build selection rectangle area
        final overlay = OverlayEntry(
          builder: (context) => MobileSelectionWidget(
            selectionColor: widget.selectionColor,
            selectionHandleColor: widget.selectionHandleColor,
            layerLink: node.layerLink,
            selectionRect: selectionRect,
            handleType: HandleType.none,
          ),
        );
        _selectionOverlayEntries.add(overlay);

        // Add selection handles when we build the first and last rect.
        if (i == 0 && selectionRect == selectionRects.first) {
          final leftHandlerOverlay = OverlayEntry(
            builder: (context) => MobileSelectionWidget(
              selectionColor: widget.selectionColor,
              selectionHandleColor: widget.selectionHandleColor,
              layerLink: node.layerLink,
              selectionRect: selectionRect,
              handleType: HandleType.up,
            ),
          );
          // 2 is the hanlder width in MobileSelectionWidget
          _leftHandlerRect = Rect.fromLTWH(
            selectionRect.left - 2,
            selectionRect.top,
            2,
            selectionRect.height,
          );
          _selectionOverlayEntries.add(leftHandlerOverlay);
        }
        if (i == nodes.length - 1 && selectionRect == selectionRects.last) {
          final rightHandlerOverlay = OverlayEntry(
            builder: (context) => MobileSelectionWidget(
              selectionColor: widget.selectionColor,
              selectionHandleColor: widget.selectionHandleColor,
              layerLink: node.layerLink,
              selectionRect: selectionRect,
              handleType: HandleType.down,
            ),
          );
          _rightHandlerRect = Rect.fromLTWH(
            selectionRect.right - 2,
            selectionRect.top,
            2,
            selectionRect.height,
          );
          _selectionOverlayEntries.add(rightHandlerOverlay);
        }
      }
    }
    final overlay = Overlay.of(context);
    overlay?.insertAll(
      _selectionOverlayEntries,
    );
  }

  /// Render cursor
  void _updateCursor(Position position) {
    final node = editorState.document.root.childAtPath(position.path);

    if (node == null) {
      assert(false);
      return;
    }

    final selectable = node.selectable;
    final cursorRect = selectable?.getCursorRectInPosition(position);

    if (selectable != null && cursorRect != null) {
      final cursorEntry = OverlayEntry(
        key: _cursorKey,
        builder: (context) => CursorWidget(
          rect: cursorRect,
          color: widget.cursorColor,
          layerLink: node.layerLink,
          shouldBlink: selectable.shouldCursorBlink,
          cursorStyle: selectable.cursorStyle,
        ),
      );
      _cursorOverlayEntry = cursorEntry;
      Overlay.of(context)?.insert(cursorEntry);

      // Force cursor always show 100% opacity at the begining
      _cursorKey.currentState?.unwrapOrNull<CursorWidgetState>()?.show();
    }
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

  void _onTapUp(TapUpDetails tapUpDetails) {
    Log.selection.debug(
      'onTapUp global: ${tapUpDetails.globalPosition} local :${tapUpDetails.localPosition} }',
    );
    // Get offset to be used in [onTap]
    _tapUpOffset = tapUpDetails.globalPosition;
  }

  void _onTap() {
    Log.selection.debug('onTap');
    // update the selection in editor state base on user's tap position
    if (_tapUpOffset == null) return;
    final position = getPositionInOffset(_tapUpOffset!);
    print('position');
    print(position);
    if (position == null) return;
    editorState.selection = Selection.collapsed(position);

    // record the cursorRect(related to node) to be used in [onPanUpdate] to achieve cursor moving along the pan moving
    final node = editorState.document.root.childAtPath(position.path);
    if (node == null) {
      assert(false);
      return;
    }
    _cursorRect = node.selectable?.getCursorRectInPosition(position);
    // _leftHandlerRect == null;
    // _rightHandlerRect == null;

    // print('selection');
    // print(editorState.selection);
    // print('selectionRects: ${editorState}');

    // reset the offset [onTap]
    _tapUpOffset = null;
  }

  void _onDoubleTapDown(TapDownDetails doubleTapDownDetails) {
    Log.selection.debug(
      'onDoubleTapDown global: ${doubleTapDownDetails.globalPosition} local :${doubleTapDownDetails.localPosition}',
    );
    // Get offset to be used in [onDoubleTap]
    _doubleTapDownOffset = doubleTapDownDetails.globalPosition;
  }

  void _onDoubleTap() {
    Log.selection.debug('onDoubleTap');
    if (_doubleTapDownOffset == null) return;
    // update the selection in editor state base on user's tap position
    final node = getNodeInOffset(_doubleTapDownOffset!);
    var selection =
        node?.selectable?.getWordBoundaryInOffset(_doubleTapDownOffset!);
    if (selection == null) {
      clearSelection();
      return;
    }
    Log.selection.debug('input seleciton ${selection.isForward}');
    // TODO(yijing): to avoid select a space when users double tapping
    editorState.selection = selection;
    // _cursorRect == null;
    _doubleTapDownOffset = null;
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    Log.selection.debug(
      'onLongPressMoveUpdate global: ${details.globalPosition} local :${details.localPosition}',
    );

    final offset = details.globalPosition;
    final selection = editorState.selection;
    if (selection == null) return;
    // TODO(yijing):Fix the cursor didn't update when dragging in the beginning of the line.
    if (selection.isCollapsed) {
      if (_isOverCursor(offset) == true) {
        final position = getPositionInOffset(offset);
        if (position == null) return;
        editorState.selection = Selection.collapsed(position);
        return;
      }
    }
    if (_isOverLeftHandler(offset) == true) {
      final position = getPositionInOffset(offset);
      editorState.selection = editorState.selection!.copyWith(
        start: position,
      );
    }
    if (_isOverRightHandler(offset) == true) {
      final position = getPositionInOffset(offset);

      editorState.selection = editorState.selection!.copyWith(
        end: position,
      );
    }
  }

  // The following methods decide if the current position(Offset) is over certain widget(cursor, left handler, right handler)

  /// Check the point offset is over cursor
  bool _isOverCursor(Offset pointOffset) {
    // get current cursor rect from every time when user [onTap]
    if (_cursorRect == null) {
      return false;
    }
    // expand the sensing area for cursor
    final cursorSensingRect =
        Rect.fromLTWH(_cursorRect!.left - 1, _cursorRect!.center.dy, 1, 1)
            .inflate(24);

    // get the local offset for the current point
    final node = getNodeInOffset(pointOffset);
    if (node == null || node.selectable == null) {
      return false;
    }
    final localOffset = node.selectable!.globalToLocal(pointOffset);

    // check if the local offset is in the sensing area
    return (cursorSensingRect.contains(localOffset));
  }

  /// Check the point offset is over the left handler
  bool _isOverLeftHandler(Offset pointOffset) {
    // get left handler rect from every time when user [onDoubleTap]
    if (_leftHandlerRect == null) {
      return false;
    }
    // expand the sensing area for cursor
    final leftHandlerSensingRect = Rect.fromLTWH(
      _leftHandlerRect!.left + 6,
      _leftHandlerRect!.top + 6,
      14,
      _leftHandlerRect!.height,
    ).inflate(8);

    // get the local offset for the current point
    final node = getNodeInOffset(pointOffset);
    if (node == null || node.selectable == null) {
      return false;
    }
    final localOffset = node.selectable!.globalToLocal(pointOffset);

    // check if the local offset is in the sensing area
    return (leftHandlerSensingRect.contains(localOffset));
  }

  /// Check the point offset is over the right handler
  bool _isOverRightHandler(Offset pointOffset) {
    // get right handler rect from every time when user [onDoubleTap]
    if (_rightHandlerRect == null) {
      return false;
    }
    // expand the sensing area for cursor
    final rightHandlerSensingRect = Rect.fromLTWH(
      _rightHandlerRect!.left - 6,
      _rightHandlerRect!.top,
      14,
      _rightHandlerRect!.height + 6,
    ).inflate(8);

    // get the local offset for the current point
    final node = getNodeInOffset(pointOffset);
    if (node == null || node.selectable == null) {
      return false;
    }
    final localOffset = node.selectable!.globalToLocal(pointOffset);

    // check if the local offset is in the sensing area
    return (rightHandlerSensingRect.contains(localOffset));
  }
}
