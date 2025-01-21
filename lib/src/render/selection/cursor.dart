import 'dart:async';

import 'package:appflowy_editor/src/render/selection/selectable.dart';
import 'package:flutter/material.dart';

class Cursor extends StatefulWidget {
  const Cursor({
    super.key,
    required this.rect,
    required this.color,
    this.blinkingInterval = 0.5,
    this.shouldBlink = true,
    this.cursorStyle = CursorStyle.verticalLine,
  });

  final double blinkingInterval; // milliseconds
  final bool shouldBlink;
  final CursorStyle cursorStyle;
  final Color color;
  final Rect rect;

  @override
  State<Cursor> createState() => CursorState();
}

class CursorState extends State<Cursor> {
  bool showCursor = true;
  late Timer timer;

  @override
  void initState() {
    super.initState();

    timer = _initTimer();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Timer _initTimer() {
    return Timer.periodic(
      Duration(milliseconds: (widget.blinkingInterval * 1000).toInt()),
      (timer) => setState(() => showCursor = !showCursor),
    );
  }

  /// force the cursor widget to show for a while
  void show() {
    setState(() {
      showCursor = true;
    });
    timer.cancel();
    timer = _initTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fromRect(
      rect: widget.rect,
      child: IgnorePointer(
        child: _buildCursor(context),
      ),
    );
  }

  Widget _buildCursor(BuildContext context) {
    var color = widget.color;
    if (widget.shouldBlink && !showCursor) {
      color = Colors.transparent;
    }
    switch (widget.cursorStyle) {
      case CursorStyle.verticalLine:
        return Container(
          color: color,
        );
      case CursorStyle.borderLine:
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 2),
          ),
        );
      case CursorStyle.cover:
        final size = widget.rect.size;
        return Container(
          width: size.width,
          height: size.height,
          color: color.withOpacity(0.2),
        );
    }
  }
}
