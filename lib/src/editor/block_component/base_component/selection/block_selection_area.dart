import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/base_component/selection/selection_area_painter.dart';
import 'package:appflowy_editor/src/render/selection/cursor.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final _deepEqual = const DeepCollectionEquality().equals;

enum BlockSelectionType {
  cursor,
  selection,
  block,
}

/// [BlockSelectionArea] is a widget that renders the selection area or the cursor of a block.
class BlockSelectionArea extends StatefulWidget {
  const BlockSelectionArea({
    super.key,
    required this.node,
    required this.delegate,
    required this.listenable,
    required this.cursorColor,
    required this.selectionColor,
    required this.blockColor,
    this.supportTypes = const [
      BlockSelectionType.cursor,
      BlockSelectionType.selection,
    ],
  });

  // get the cursor rect or selection rects from the delegate
  final SelectableMixin delegate;

  // get the selection from the listenable
  final ValueListenable<Selection?> listenable;

  // the color of the cursor
  final Color cursorColor;

  // the color of the selection
  final Color selectionColor;

  final Color blockColor;

  // the node of the block
  final Node node;

  final List<BlockSelectionType> supportTypes;

  @override
  State<BlockSelectionArea> createState() => _BlockSelectionAreaState();
}

class _BlockSelectionAreaState extends State<BlockSelectionArea> {
  // We need to keep the key to refresh the cursor status when typing continuously.
  late GlobalKey cursorKey = GlobalKey(
    debugLabel: 'cursor_${widget.node.path}',
  );

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
    widget.listenable.addListener(_clearCursorRect);
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_clearCursorRect);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      key: ValueKey(widget.node.id + widget.supportTypes.toString()),
      valueListenable: widget.listenable,
      builder: ((context, value, child) {
        final sizedBox = child ?? const SizedBox.shrink();
        final selection = value?.normalized;
        final editorState = context.watch<EditorState>();
        final rect = prevCursorRect ?? Rect.zero;
        if (selection == null) {
          //NOTE: This just makes every node that can be selected
          return sizedBox;
        }

        final path = widget.node.path;
        if (editorState.mode == VimModes.normalMode) {
          if (!widget.supportTypes.contains(BlockSelectionType.selection) ||
              prevSelectionRects == null ||
              prevSelectionRects!.isEmpty) {
            return sizedBox;
          }

          final cursor = Cursor(
            key: cursorKey,
            rect: rect,
            shouldBlink: false,
            cursorStyle: CursorStyle.block,
            color: Colors.blue,
          );
          cursorKey.currentState?.unwrapOrNull<CursorState>()?.show();
          return cursor;
        }

        if (!path.inSelection(selection)) {
          return sizedBox;
        }
        //NOTE: Include this in Insert Mode?
        if (context.read<EditorState>().selectionType == SelectionType.block) {
          if (!widget.supportTypes.contains(BlockSelectionType.block) ||
              !path.equals(selection.start.path) ||
              prevBlockRect == null) {
            return sizedBox;
          }
          return Positioned.fromRect(
            rect: prevBlockRect!,
            child: Container(
              decoration: BoxDecoration(
                color: widget.blockColor,
                borderRadius: BorderRadius.circular(0.0),
              ),
            ),
          );
        }
        // show the cursor when the selection is collapsed
        else if (selection.isCollapsed &&
            editorState.mode == VimModes.insertMode) {
          if (!widget.supportTypes.contains(BlockSelectionType.cursor) ||
              prevCursorRect == null) {
            return sizedBox;
          }
          final cursor = Cursor(
            key: cursorKey,
            rect: prevCursorRect!,
            shouldBlink: widget.delegate.shouldCursorBlink,
            cursorStyle: widget.delegate.cursorStyle,
            color: widget.cursorColor,
          );
          // force to show the cursor
          cursorKey.currentState?.unwrapOrNull<CursorState>()?.show();
          return cursor;
        } else {
          // show the selection area when the selection is not collapsed
          if (!widget.supportTypes.contains(BlockSelectionType.selection) ||
              prevSelectionRects == null ||
              prevSelectionRects!.isEmpty) {
            return sizedBox;
          }
          return SelectionAreaPaint(
            rects: prevSelectionRects!,
            selectionColor: widget.selectionColor,
          );
        }
      }),
      child: const SizedBox.shrink(),
    );
  }

  void _updateSelectionIfNeeded() {
    if (!mounted) {
      return;
    }

    final selection = widget.listenable.value?.normalized;
    final path = widget.node.path;

    // the current path is in the selection
    if (selection != null && path.inSelection(selection)) {
      if (widget.supportTypes.contains(BlockSelectionType.block) &&
          context.read<EditorState>().selectionType == SelectionType.block) {
        if (!path.equals(selection.start.path)) {
          if (prevBlockRect != null) {
            setState(() {
              prevBlockRect = null;
              prevCursorRect = null;
              prevSelectionRects = null;
            });
          }
        } else {
          final rect = widget.delegate.getBlockRect();
          if (prevBlockRect != rect) {
            setState(() {
              prevBlockRect = rect;
              prevCursorRect = null;
              prevSelectionRects = null;
            });
          }
        }
      } else if (widget.supportTypes.contains(BlockSelectionType.cursor) &&
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

  void _clearCursorRect() {
    prevCursorRect = null;
  }
}
