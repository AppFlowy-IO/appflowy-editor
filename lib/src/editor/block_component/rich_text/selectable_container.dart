import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/render/selection/cursor.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SelectableContainer extends StatefulWidget {
  const SelectableContainer({
    super.key,
    required this.delegate,
    required this.listenable,
    required this.node,
    required this.selectionColor,
  });

  final SelectableMixin delegate;
  final ValueListenable<Selection?> listenable;
  final Color selectionColor;

  final Node node;

  @override
  State<SelectableContainer> createState() => _SelectableContainerState();
}

class _SelectableContainerState extends State<SelectableContainer> {
  Rect? cursorRect;
  List<Rect>? selectionRects;

  late GlobalKey cursorKey =
      GlobalKey(debugLabel: 'cursor_${widget.node.path}');

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
        if (value == null) {
          return child!;
        }

        value = value.normalized;

        if (value.start.path > widget.node.path ||
            widget.node.path > value.end.path) {
          return child!;
        }

        if (value.isCollapsed && value.start.path.equals(widget.node.path)) {
          final rect = widget.delegate.getCursorRectInPosition(value.start);
          cursorRect = rect;
          if (rect == null) {
            return child!;
          }
          final cursor = Cursor(
            key: cursorKey,
            rect: rect,
            color: Colors.black,
          );
          cursorKey.currentState?.unwrapOrNull<CursorState>()?.show();
          return cursor;
        } else if (value.start.path <= widget.node.path &&
            widget.node.path <= value.end.path) {
          final rects = widget.delegate.getRectsInSelection(value);
          selectionRects = rects;
          if (rects.isEmpty) {
            return child!;
          }
          return CustomPaint(
            painter: _SelectionPainter(
              rects: rects,
              selectionColor: widget.selectionColor,
            ),
          );
        }

        return child!;
      }),
      child: const SizedBox.shrink(),
    );
  }

  void _updateSelectionIfNeeded() {
    if (!mounted) {
      return;
    }

    final selection = widget.listenable.value;

    if (selection == null) {
    } else {
      if (selection.start.path > widget.node.path ||
          widget.node.path > selection.end.path) {
      } else {
        if (selection.isCollapsed) {
          final rect = widget.delegate.getCursorRectInPosition(selection.start);
          if (rect != cursorRect) {
            setState(() {});
          }
        } else {
          final rects = widget.delegate.getRectsInSelection(selection);
          if (!const DeepCollectionEquality().equals(rects, selectionRects)) {
            setState(() {});
          }
        }
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _updateSelectionIfNeeded();
    });
  }
}

class _SelectionPainter extends CustomPainter {
  _SelectionPainter({
    required this.rects,
    required this.selectionColor,
  });

  final List<Rect> rects;
  final Color selectionColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Define the paint style for the rectangles
    final paint = Paint()
      ..color = selectionColor
      ..style = PaintingStyle.fill;

    for (final rect in rects) {
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // Return false because the paint operation does not depend on any external data.
    return true;
  }
}
