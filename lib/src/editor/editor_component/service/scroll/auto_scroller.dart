import 'package:flutter/material.dart';

abstract class AutoScrollerService {
  void startAutoScroll(Offset offset);
  void stopAutoScroll();
}

class AutoScroller extends EdgeDraggingAutoScroller
    implements AutoScrollerService {
  AutoScroller(
    super.scrollable, {
    this.edgeOffset = 200,
    super.onScrollViewScrolled,
    super.velocityScalar = _kDefaultAutoScrollVelocityScalar,
  });

  static const double _kDefaultAutoScrollVelocityScalar = 7;

  final double edgeOffset;

  @override
  void startAutoScroll(Offset offset) {
    startAutoScrollIfNecessary(
      offset.translate(0, -edgeOffset) & Size(1, 2 * edgeOffset),
    );
  }
}
