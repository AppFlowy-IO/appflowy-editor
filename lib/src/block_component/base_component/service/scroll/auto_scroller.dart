import 'package:flutter/material.dart';

abstract class AutoScrollerService {
  void startAutoScrollIfNecessary(Rect dragTarget);
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
}
