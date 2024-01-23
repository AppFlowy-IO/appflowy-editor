import 'package:flutter/material.dart';

class DashedCursor extends StatelessWidget {
  const DashedCursor({
    super.key,
    required this.color,
    required this.strokeCap,
    required this.strokeWidth,
  });

  final Color color;
  final double strokeWidth;
  final StrokeCap strokeCap;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashedCursorPainter(
        color: color,
        strokeCap: strokeCap,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class DashedCursorPainter extends CustomPainter {
  DashedCursorPainter({
    required this.color,
    required this.strokeCap,
    required this.strokeWidth,
  });

  final Color color;
  final double strokeWidth;
  final StrokeCap strokeCap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;
    //..strokeCap = strokeCap;

    double height = size.height + 2;
    for (double i = 0; i < height; i += 5) {
      canvas.drawLine(
        Offset(size.width, i),
        Offset(size.width, i + 2.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(DashedCursorPainter oldDelegate) {
    return color != oldDelegate.color ||
        strokeCap != oldDelegate.strokeCap ||
        strokeWidth != oldDelegate.strokeWidth;
  }
}
