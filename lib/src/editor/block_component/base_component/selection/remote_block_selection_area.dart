import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/base_component/selection/selection_area_painter.dart';
import 'package:appflowy_editor/src/render/selection/cursor.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

final _deepEqual = const DeepCollectionEquality().equals;

class RemoteBlockSelectionsArea extends StatelessWidget {
  const RemoteBlockSelectionsArea({
    super.key,
    required this.node,
    required this.delegate,
    required this.remoteSelections,
    this.supportTypes = const [
      BlockSelectionType.cursor,
      BlockSelectionType.selection,
    ],
  });

  // get the cursor rect or selection rects from the delegate
  final SelectableMixin delegate;

  final ValueListenable<List<RemoteSelection>> remoteSelections;

  // the node of the block
  final Node node;

  final List<BlockSelectionType> supportTypes;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: remoteSelections,
      builder: (_, value, child) {
        child ??= const SizedBox.shrink();
        final selections = value
            .where((e) => node.inSelection(e.selection.normalized))
            .toList();
        if (selections.isEmpty) {
          return child;
        }
        return Positioned.fill(
          child: Stack(
            children: selections
                .map(
                  (e) => RemoteBlockSelectionArea(
                    node: node,
                    delegate: delegate,
                    remoteSelection: e,
                    supportTypes: supportTypes,
                  ),
                )
                .toList(),
          ),
        );
      },
      child: const SizedBox.shrink(),
    );
  }
}

/// [RemoteBlockSelectionArea] is a widget that renders the selection area or the cursor of a block from remote.
class RemoteBlockSelectionArea extends StatefulWidget {
  const RemoteBlockSelectionArea({
    super.key,
    required this.node,
    required this.delegate,
    required this.remoteSelection,
    this.supportTypes = const [
      BlockSelectionType.cursor,
      BlockSelectionType.selection,
    ],
  });

  // get the cursor rect or selection rects from the delegate
  final SelectableMixin delegate;

  final RemoteSelection remoteSelection;

  // the node of the block
  final Node node;

  final List<BlockSelectionType> supportTypes;

  @override
  State<RemoteBlockSelectionArea> createState() =>
      _RemoteBlockSelectionAreaState();
}

class _RemoteBlockSelectionAreaState extends State<RemoteBlockSelectionArea> {
  // keep the previous cursor rect to avoid unnecessary rebuild
  Rect? prevCursorRect;
  // keep the previous selection rects to avoid unnecessary rebuild
  List<Rect>? prevSelectionRects;
  // keep the block selection rect to avoid unnecessary rebuild
  Rect? prevBlockRect;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSelectionIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    const child = SizedBox.shrink();
    final selection = widget.remoteSelection.selection;
    if (selection.isCollapsed) {
      // show the cursor when the selection is collapsed
      if (!widget.supportTypes.contains(BlockSelectionType.cursor) ||
          prevCursorRect == null) {
        return child;
      }
      const shouldBlink = false;
      final cursor = Stack(
        clipBehavior: Clip.none,
        children: [
          Cursor(
            rect: prevCursorRect!,
            shouldBlink: shouldBlink,
            cursorStyle: widget.delegate.cursorStyle,
            color: widget.remoteSelection.cursorColor,
          ),
          widget.remoteSelection.builder?.call(
                context,
                widget.remoteSelection,
                prevCursorRect!,
              ) ??
              child,
        ],
      );
      return cursor;
    } else {
      // show the selection area when the selection is not collapsed
      if (!widget.supportTypes.contains(BlockSelectionType.selection) ||
          prevSelectionRects == null ||
          prevSelectionRects!.isEmpty ||
          (prevSelectionRects!.length == 1 &&
              prevSelectionRects!.first.width == 0)) {
        return child;
      }
      return Stack(
        clipBehavior: Clip.none,
        children: [
          SelectionAreaPaint(
            rects: prevSelectionRects!,
            selectionColor: widget.remoteSelection.selectionColor,
          ),
          if (selection.start.path.equals(widget.node.path))
            widget.remoteSelection.builder?.call(
                  context,
                  widget.remoteSelection,
                  prevSelectionRects!.first,
                ) ??
                child,
        ],
      );
    }
  }

  void _updateSelectionIfNeeded() {
    if (!mounted) {
      return;
    }

    final selection = widget.remoteSelection.selection.normalized;
    final path = widget.node.path;

    // the current path is in the selection
    if (path.inSelection(selection)) {
      if (widget.supportTypes.contains(BlockSelectionType.cursor) &&
          selection.isCollapsed) {
        final rect = widget.delegate.getCursorRectInPosition(selection.start);
        if (rect != prevCursorRect) {
          setState(() {
            prevCursorRect = rect;
            prevBlockRect = null;
            prevSelectionRects = null;
          });
        }
      } else if (widget.supportTypes.contains(BlockSelectionType.selection)) {
        final rects = widget.delegate.getRectsInSelection(selection);
        if (!_deepEqual(rects, prevSelectionRects)) {
          setState(() {
            prevSelectionRects = rects;
            prevCursorRect = null;
            prevBlockRect = null;
          });
        }
      }
    } else if (prevBlockRect != null ||
        prevSelectionRects != null ||
        prevCursorRect != null) {
      setState(() {
        prevBlockRect = null;
        prevSelectionRects = null;
        prevCursorRect = null;
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _updateSelectionIfNeeded();
    });
  }
}
