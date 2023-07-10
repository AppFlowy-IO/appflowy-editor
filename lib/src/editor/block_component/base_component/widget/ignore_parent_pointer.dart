import 'package:flutter/material.dart';

class IgnoreParentPointer extends StatelessWidget {
  const IgnoreParentPointer({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      onDoubleTap: () {},
      onLongPress: () {},
      child: child,
    );
  }
}
