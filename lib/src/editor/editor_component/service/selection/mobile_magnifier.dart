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
    // the magnifier will blink if the center is the same as the offset.
    final magicOffset = Offset(0, size.height - 22);
    return Positioned.fromRect(
      rect: Rect.fromCenter(
        center: offset - magicOffset,
        width: size.width,
        height: size.height,
      ),
      child: IgnorePointer(
        child: _CustomMagnifier(
          size: size,
          additionalFocalPointOffset: magicOffset,
        ),
      ),
    );
  }
}

class _CustomMagnifier extends StatelessWidget {
  const _CustomMagnifier({
    this.additionalFocalPointOffset = Offset.zero,
    required this.size,
  });

  final Size size;
  final Offset additionalFocalPointOffset;

  @override
  Widget build(BuildContext context) {
    return RawMagnifier(
      decoration: const MagnifierDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(40)),
        ),
        shadows: <BoxShadow>[
          BoxShadow(
            blurRadius: 1.5,
            offset: Offset(0, 2),
            spreadRadius: 0.75,
            color: Color.fromARGB(25, 0, 0, 0),
          ),
        ],
      ),
      magnificationScale: 1.25,
      focalPointOffset: additionalFocalPointOffset,
      size: size,
      child: const ColoredBox(
        color: Color.fromARGB(8, 158, 158, 158),
      ),
    );
  }
}
