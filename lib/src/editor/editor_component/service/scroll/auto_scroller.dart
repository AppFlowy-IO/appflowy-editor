import 'package:flutter/material.dart';

abstract class AutoScrollerService {
  void startAutoScroll(
    Offset offset, {
    double edgeOffset = 200,
    AxisDirection? direction,
  });
  void stopAutoScroll();
}

class AutoScroller extends EdgeDraggingAutoScroller
    implements AutoScrollerService {
  AutoScroller(
    super.scrollable, {
    super.onScrollViewScrolled,
    super.velocityScalar = _kDefaultAutoScrollVelocityScalar,
  });

  static const double _kDefaultAutoScrollVelocityScalar = 7;

  @override
  void startAutoScroll(
    Offset offset, {
    double edgeOffset = 200,
    AxisDirection? direction,
  }) {
    if (direction != null) {
      if (direction == AxisDirection.up) {
        startAutoScrollIfNecessary(
          offset & Size(1, edgeOffset),
        );
      }
    } else {
      startAutoScrollIfNecessary(
        offset.translate(0, -edgeOffset) & Size(1, 2 * edgeOffset),
      );
    }
  }
}
