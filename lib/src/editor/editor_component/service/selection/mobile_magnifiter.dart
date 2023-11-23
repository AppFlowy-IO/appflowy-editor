import 'package:flutter/material.dart';

class MobileMagnifier extends StatelessWidget {
  const MobileMagnifier({
    super.key,
    required this.size,
    required this.offset,
  });

  final Size size;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Positioned.fromRect(
      rect: Rect.fromCenter(
        center: offset.translate(0, -size.height),
        width: size.width,
        height: size.height,
      ),
      child: IgnorePointer(
        child: Magnifier(
          size: size,
        ),
      ),
    );
  }
}
