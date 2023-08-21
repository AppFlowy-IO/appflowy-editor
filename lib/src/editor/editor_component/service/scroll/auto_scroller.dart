import 'package:appflowy_editor/src/flutter/scrollable_helpers.dart';
import 'package:flutter/material.dart' hide EdgeDraggingAutoScroller;

abstract class AutoScrollerService {
  void startAutoScroll(
    Offset offset, {
    double edgeOffset = 200,
    AxisDirection? direction,
    Duration? duration,
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
    Duration? duration,
  }) {
    if (direction != null && direction == AxisDirection.up) {
      return startAutoScrollIfNecessary(
        offset & Size(1, edgeOffset),
        duration: duration,
      );
    }

    lastOffset = offset;
    final dragTarget = Rect.fromCenter(
      center: offset,
      width: edgeOffset,
      height: edgeOffset,
    );

    startAutoScrollIfNecessary(
      dragTarget,
      duration: duration,
    );
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
