import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class AnimatedSelectionAreaPaint extends StatefulWidget {
  const AnimatedSelectionAreaPaint({
    super.key,
    required this.rects,
    this.withAnimation = false,
    s,
  });

  final List<Rect> rects;
  final bool withAnimation;

  @override
  State<AnimatedSelectionAreaPaint> createState() =>
      _AnimatedSelectionAreaPaintState();
}

class _AnimatedSelectionAreaPaintState extends State<AnimatedSelectionAreaPaint>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    if (widget.withAnimation) {
      controller = AnimationController(
        duration: const Duration(seconds: 4),
        vsync: this,
      );
      animation = Tween<double>(begin: 0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.bounceInOut,
        ),
      );
      controller.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget builder(double value) {
      return CustomPaint(
        painter: AnimatedSelectionAreaPainter(
          colors: const [
            Color.fromARGB(255, 65, 88, 208),
            Color.fromARGB(255, 200, 80, 192),
            Color.fromARGB(255, 255, 204, 112),
          ],
          animation: value,
          rects: widget.rects,
        ),
      );
    }

    if (!widget.withAnimation) {
      return builder(1.0);
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, _) {
        return builder(animation.value);
      },
    );
  }

  @override
  void dispose() {
    if (widget.withAnimation) {
      controller.dispose();
    }

    super.dispose();
  }
}

class SelectionAreaPaint extends StatelessWidget {
  const SelectionAreaPaint({
    super.key,
    required this.rects,
    required this.selectionColor,
  });

  final List<Rect> rects;
  final Color selectionColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SelectionAreaPainter(
        rects: rects,
        selectionColor: selectionColor,
      ),
    );
  }
}

class SelectionAreaPainter extends CustomPainter {
  SelectionAreaPainter({
    required this.rects,
    required this.selectionColor,
  });

  final List<Rect> rects;
  final Color selectionColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = selectionColor
      ..style = PaintingStyle.fill;

    for (var rect in rects) {
      // if rect.width is 0, we draw a small rect to indicate the selection area
      if (rect.width <= 0) {
        rect = Rect.fromLTWH(rect.left, rect.top, 8.0, rect.height);
      }
      canvas.drawRect(
        rect,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(SelectionAreaPainter oldDelegate) {
    return selectionColor != oldDelegate.selectionColor ||
        !const DeepCollectionEquality().equals(rects, oldDelegate.rects);
  }
}

class AnimatedSelectionAreaPainter extends CustomPainter {
  const AnimatedSelectionAreaPainter({
    required this.rects,
    required this.colors,
    required this.animation,
  });

  final List<Rect> rects;
  final List<Color> colors;
  final double animation;

  @override
  void paint(Canvas canvas, Size size) {
    for (final rect in rects) {
      final paint = Paint()
        ..shader = LinearGradient(
          colors: colors,
          transform: GradientRotation(animation * 2 * pi),
        ).createShader(rect)
        ..style = PaintingStyle.fill;

      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant AnimatedSelectionAreaPainter oldDelegate) {
    return animation != oldDelegate.animation ||
        !const DeepCollectionEquality().equals(colors, oldDelegate.colors) ||
        !const DeepCollectionEquality().equals(rects, oldDelegate.rects);
  }
}
