import 'dart:math' as math;

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
    super.minimumAutoScrollDelta = _kDefaultMinAutoScrollDelta,
    super.maxAutoScrollDelta = _kDefaultMaxAutoScrollDelta,
    super.animationDuration,
    this.topInset = 0.0,
  });

  /// The height of the area at the top of the screen that is covered by the
  /// host application and that overlaps the editor.
  ///
  /// See [AppFlowyEditor.autoScrollTopInset].
  double topInset;

  static const double _kDefaultAutoScrollVelocityScalar = 7;
  static const double _kDefaultMinAutoScrollDelta = 1.0;
  static const double _kDefaultMaxAutoScrollDelta = 20.0;

  Offset? lastOffset;
  Duration? lastDuration;
  double? lastEdgeOffset;
  AxisDirection? lastDirection;

  @override
  void startAutoScroll(
    Offset offset, {
    double edgeOffset = 200,
    AxisDirection? direction,
    Duration? duration,
  }) {
    lastOffset = offset;
    lastDuration = duration;
    lastEdgeOffset = edgeOffset;
    lastDirection = direction;
    if (direction != null && direction == AxisDirection.up) {
      return startAutoScrollIfNecessary(
        Rect.fromLTWH(offset.dx, offset.dy - edgeOffset, 1, edgeOffset),
        duration: duration,
      );
    }

    if (direction != null && direction == AxisDirection.down) {
      return startAutoScrollIfNecessary(
        Rect.fromLTWH(offset.dx, offset.dy, 1, edgeOffset),
        duration: duration,
      );
    }

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
    lastDuration = null;
    lastEdgeOffset = null;
    lastDirection = null;
    super.stopAutoScroll();
  }

  void continueToAutoScroll() {
    if (lastOffset != null) {
      startAutoScroll(
        lastOffset!,
        edgeOffset: lastEdgeOffset ?? 200,
        direction: lastDirection,
        duration: lastDuration,
      );
    }
  }

  /// The area of the screen that is actually visible to the user.
  ///
  /// The viewport of the editor is not always the visible area of the screen.
  /// A host application may render the editor behind the system status bar or
  /// behind the on screen keyboard, in which case the edges of the viewport
  /// are not reachable for the user. The auto scroll is triggered relative to
  /// this rectangle instead, so that the document starts to scroll while the
  /// selection handle is still visible.
  ///
  /// The insets are taken from the [View] instead of the [MediaQuery],
  /// because they are relative to the screen and not to the region of the
  /// [MediaQuery] that the editor happens to live in.
  Rect? get _visibleScreenRect {
    final view = View.maybeOf(scrollable.context);
    if (view == null) {
      return null;
    }

    final dpr = view.devicePixelRatio;
    final size = view.physicalSize / dpr;
    // the status bar and the area that the host application covers are not
    // visible to the user.
    final top = view.padding.top / dpr + topInset;
    // the on screen keyboard covers the bottom of the screen.
    final bottom = view.viewInsets.bottom / dpr;

    return Rect.fromLTRB(0, top, size.width, size.height - bottom);
  }

  @override
  Rect resolveViewportRect(Rect globalRect) {
    final visibleRect = _visibleScreenRect;
    if (visibleRect == null) {
      return globalRect;
    }

    return Rect.fromLTRB(
      globalRect.left,
      math.max(globalRect.top, visibleRect.top),
      globalRect.right,
      math.min(globalRect.bottom, visibleRect.bottom),
    );
  }
}
