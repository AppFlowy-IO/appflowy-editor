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

  Offset? lastOffset;

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
      lastOffset = offset;
      final dragTarget = Rect.fromCenter(
        center: offset,
        width: edgeOffset,
        height: edgeOffset,
      );
      startAutoScrollIfNecessary(dragTarget);
    }
  }

  @override
  void stopAutoScroll() {
    lastOffset = null;
    super.stopAutoScroll();
  }

  void continueToAutoScroll() {
    if (lastOffset != null) {
      startAutoScroll(lastOffset!);
    }
  }
}
