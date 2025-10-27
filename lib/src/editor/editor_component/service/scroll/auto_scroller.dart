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
    ScrollableState scrollable, {
    VoidCallback? onScrollViewScrolled,
    double velocityScalar = _kDefaultAutoScrollVelocityScalar,
    double minAutoScrollDelta = _kDefaultMinAutoScrollDelta,
    double maxAutoScrollDelta = _kDefaultMaxAutoScrollDelta,
  }) : super(
          scrollable,
          onScrollViewScrolled: onScrollViewScrolled,
          velocityScalar: velocityScalar,
          minimumAutoScrollDelta: minAutoScrollDelta,
          maxAutoScrollDelta: maxAutoScrollDelta,
        );

  static const double _kDefaultAutoScrollVelocityScalar = 7;
  static const double _kDefaultMinAutoScrollDelta = 1.0;
  static const double _kDefaultMaxAutoScrollDelta = 20.0;

  Offset? lastOffset;
  Duration? lastDuration;

  @override
  void startAutoScroll(
    Offset offset, {
    double edgeOffset = 200,
    AxisDirection? direction,
    Duration? duration,
  }) {
    lastOffset = offset;
    lastDuration = duration;
    if (direction != null && direction == AxisDirection.up) {
      return startAutoScrollIfNecessary(
        offset & Size(1, edgeOffset),
      );
    }

    final dragTarget = Rect.fromCenter(
      center: offset,
      width: edgeOffset,
      height: edgeOffset,
    );

    startAutoScrollIfNecessary(
      dragTarget,
    );
  }

  @override
  void stopAutoScroll() {
    lastOffset = null;
    lastDuration = null;
    super.stopAutoScroll();
  }

  void continueToAutoScroll() {
    if (lastOffset != null) {
      startAutoScroll(
        lastOffset!,
        duration: lastDuration,
      );
    }
  }
}
