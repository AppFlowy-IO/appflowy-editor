import 'package:flutter/material.dart';

enum HandleType {
  none,
  up,
  down,
}

class MobileSelectionWidget extends StatelessWidget {
  /// Render hanlders or selection rectangle based on handleType
  const MobileSelectionWidget({
    Key? key,
    required this.layerLink,
    required this.selectionRect,
    required this.selectionColor,
    required this.selectionHandleColor,
    this.handleType = HandleType.none,
  }) : super(key: key);

  final Color selectionColor;
  final Color selectionHandleColor;
  final Rect selectionRect;
  final LayerLink layerLink;
  final HandleType handleType;

  @override
  Widget build(BuildContext context) {
    return Positioned.fromRect(
      rect: selectionRect,
      child: CompositedTransformFollower(
        link: layerLink,
        // The overlay will be placed at the top left corner of every selectionRect.
        offset: Offset.zero,
        // Overlay won't show on the screen when navigate to other pages
        showWhenUnlinked: false,
        child: _buildCustomPaint(handleType),
      ),
    );
  }

  /// Based on different handleType, build the corresponding CustomPaint widget
  Widget _buildCustomPaint(HandleType handleType) {
    const handleWidth = 2.0;
    CustomPainter painter;
    switch (handleType) {
      case HandleType.none:
        painter = _SelectionPainter(color: selectionColor, rect: selectionRect);
        break;
      case HandleType.up:
        painter = _HandlePainter(
          color: selectionHandleColor,
          // Covert selectionRect to handleRect
          handleRect: Rect.fromLTWH(
            selectionRect.left - handleWidth,
            selectionRect.top,
            handleWidth,
            selectionRect.height,
          ),
          isCircleUp: true,
        );
        break;
      case HandleType.down:
        painter = _HandlePainter(
          color: selectionHandleColor,
          // Covert selectionRect to handleRect
          handleRect: Rect.fromLTWH(
            selectionRect.right - handleWidth,
            selectionRect.top,
            handleWidth,
            selectionRect.height,
          ),
          isCircleUp: false,
        );
        break;
      default:
        painter = _SelectionPainter(rect: selectionRect, color: selectionColor);
    }
    return CustomPaint(
      painter: painter,
    );
  }
}

class _SelectionPainter extends CustomPainter {
  /// Draw the selection rectangle without handles
  _SelectionPainter({
    required this.color,
    required this.rect,
  });
  final Color color;
  final Rect rect;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = color;
    paint.style = PaintingStyle.fill;
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(_SelectionPainter other) {
    return true;
  }
}

class _HandlePainter extends CustomPainter {
  /// Draw the handle base on its Rect
  _HandlePainter({
    required Color color,
    required Rect handleRect,
    required bool isCircleUp,
  })  : _handleRect = handleRect,
        _isCircleUp = isCircleUp,
        _paint = Paint()..color = color;

  final Rect _handleRect;
  final Paint _paint;
  final bool _isCircleUp;

  @override
  void paint(Canvas canvas, Size size) {
    const circleSize = 4.0;
    _paint.style = PaintingStyle.fill;
    // draw the handle
    canvas.drawRect(_handleRect, _paint);
    // draw the circle connected to handle
    if (_isCircleUp) {
      canvas.drawCircle(
        Offset(_handleRect.center.dx, _handleRect.top - circleSize),
        circleSize,
        _paint,
      );
    } else {
      canvas.drawCircle(
        Offset(_handleRect.center.dx, _handleRect.bottom + circleSize),
        circleSize,
        _paint,
      );
    }
  }

  @override
  bool shouldRepaint(_HandlePainter other) {
    return true;
  }
}
