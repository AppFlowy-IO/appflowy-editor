import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/rich_text/selection/selection_area_painter.dart';
import 'package:appflowy_editor/src/render/selection/cursor.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// [BlockSelectionArea] is a widget that renders the selection area or the cursor of a block.
class BlockSelectionArea extends StatefulWidget {
  const BlockSelectionArea({
    super.key,
    required this.node,
    required this.delegate,
    required this.listenable,
    required this.cursorColor,
    required this.selectionColor,
  });

  // get the cursor rect or selection rects from the delegate
  final SelectableMixin delegate;

  // get the selection from the listenable
  final ValueListenable<Selection?> listenable;

  // the color of the cursor
  final Color cursorColor;

  // the color of the selection
  final Color selectionColor;

  // the node of the block
  final Node node;

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

  @override
  void initState() {
    super.initState();

    _updateSelectionIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.listenable,
      builder: ((context, value, child) {
        final sizedBox = child ?? const SizedBox.shrink();
        final selection = value?.normalized;

        if (selection == null) {
          return sizedBox;
        }

        final path = widget.node.path;
        if (!path.inSelection(selection)) {
          return sizedBox;
        }

        if (selection.isCollapsed) {
          if (prevCursorRect == null) {
            return sizedBox;
          }
          final cursor = Cursor(
            key: cursorKey,
            rect: prevCursorRect!,
            color: widget.cursorColor,
          );
          // force to show the cursor
          cursorKey.currentState?.unwrapOrNull<CursorState>()?.show();
          return cursor;
        } else {
          if (prevSelectionRects == null || prevSelectionRects!.isEmpty) {
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
      if (selection.isCollapsed) {
        final rect = widget.delegate.getCursorRectInPosition(selection.start);
        if (rect != prevCursorRect) {
          setState(() {
            prevCursorRect = rect;
          });
        }
      } else {
        final rects = widget.delegate.getRectsInSelection(selection);
        if (!const DeepCollectionEquality().equals(rects, prevSelectionRects)) {
          setState(() {
            prevSelectionRects = rects;
          });
        }
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _updateSelectionIfNeeded();
    });
  }
}
