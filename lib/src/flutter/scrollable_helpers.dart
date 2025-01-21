// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

export 'package:flutter/physics.dart' show Tolerance;

/// Describes the aspects of a Scrollable widget to inform inherited widgets
/// like [ScrollBehavior] for decorating.
// TODO(Piinks): Fix doc with 2DScrollable change.
// or enumerate the properties of combined
// Scrollables, such as [TwoDimensionalScrollable].
///
/// Decorations like [GlowingOverscrollIndicator]s and [Scrollbar]s require
/// information about the Scrollable in order to be initialized.
@immutable
class ScrollableDetails {
  /// Creates a set of details describing the [Scrollable]. The [direction]
  /// cannot be null.
  const ScrollableDetails({
    required this.direction,
    this.controller,
    this.physics,
    @Deprecated('Migrate to decorationClipBehavior. '
        'This property was deprecated so that its application is clearer. This clip '
        'applies to decorators, and does not directly clip a scroll view. '
        'This feature was deprecated after v3.9.0-1.0.pre.')
    Clip? clipBehavior,
    Clip? decorationClipBehavior,
  }) : decorationClipBehavior = clipBehavior ?? decorationClipBehavior;

  /// A constructor specific to a [Scrollable] with an [Axis.vertical].
  const ScrollableDetails.vertical({
    bool reverse = false,
    this.controller,
    this.physics,
    this.decorationClipBehavior,
  }) : direction = reverse ? AxisDirection.up : AxisDirection.down;

  /// A constructor specific to a [Scrollable] with an [Axis.horizontal].
  const ScrollableDetails.horizontal({
    bool reverse = false,
    this.controller,
    this.physics,
    this.decorationClipBehavior,
  }) : direction = reverse ? AxisDirection.left : AxisDirection.right;

  /// {@macro flutter.widgets.Scrollable.axisDirection}
  final AxisDirection direction;

  /// {@macro flutter.widgets.Scrollable.controller}
  final ScrollController? controller;

  /// {@macro flutter.widgets.Scrollable.physics}
  final ScrollPhysics? physics;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// This can be used by [MaterialScrollBehavior] to clip a
  /// [StretchingOverscrollIndicator].
  ///
  /// This [Clip] does not affect the [Viewport.clipBehavior], but is rather
  /// passed from the same value by [Scrollable] so that decorators like
  /// [StretchingOverscrollIndicator] honor the same clip.
  ///
  /// Defaults to null.
  final Clip? decorationClipBehavior;

  /// Deprecated getter for [decorationClipBehavior].
  @Deprecated('Migrate to decorationClipBehavior. '
      'This property was deprecated so that its application is clearer. This clip '
      'applies to decorators, and does not directly clip a scroll view. '
      'This feature was deprecated after v3.9.0-1.0.pre.')
  Clip? get clipBehavior => decorationClipBehavior;

  /// Copy the current [ScrollableDetails] with the given values replacing the
  /// current values.
  ScrollableDetails copyWith({
    AxisDirection? direction,
    ScrollController? controller,
    ScrollPhysics? physics,
    Clip? decorationClipBehavior,
  }) {
    return ScrollableDetails(
      direction: direction ?? this.direction,
      controller: controller ?? this.controller,
      physics: physics ?? this.physics,
      decorationClipBehavior:
          decorationClipBehavior ?? this.decorationClipBehavior,
    );
  }

  @override
  String toString() {
    final List<String> description = <String>[];
    description.add('axisDirection: $direction');

    void addIfNonNull(String prefix, Object? value) {
      if (value != null) {
        description.add(prefix + value.toString());
      }
    }

    addIfNonNull('scroll controller: ', controller);
    addIfNonNull('scroll physics: ', physics);
    addIfNonNull('decorationClipBehavior: ', decorationClipBehavior);
    return '${describeIdentity(this)}(${description.join(", ")})';
  }

  @override
  int get hashCode => Object.hash(
        direction,
        controller,
        physics,
        decorationClipBehavior,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ScrollableDetails &&
        other.direction == direction &&
        other.controller == controller &&
        other.physics == physics &&
        other.decorationClipBehavior == decorationClipBehavior;
  }
}

/// An auto scroller that scrolls the [scrollable] if a drag gesture drags close
/// to its edge.
///
/// The scroll velocity is controlled by the [velocityScalar]:
///
/// velocity = <distance of overscroll> * [velocityScalar].
class EdgeDraggingAutoScroller {
  /// Creates a auto scroller that scrolls the [scrollable].
  EdgeDraggingAutoScroller(
    this.scrollable, {
    this.onScrollViewScrolled,
    this.velocityScalar = _kDefaultAutoScrollVelocityScalar,
  });

  // An eyeballed value for a smooth scrolling experience.
  static const double _kDefaultAutoScrollVelocityScalar = 7;

  /// The [Scrollable] this auto scroller is scrolling.
  final ScrollableState scrollable;

  /// Called when a scroll view is scrolled.
  ///
  /// The scroll view may be scrolled multiple times in a row until the drag
  /// target no longer triggers the auto scroll. This callback will be called
  /// in between each scroll.
  final VoidCallback? onScrollViewScrolled;

  /// The velocity scalar per pixel over scroll.
  ///
  /// It represents how the velocity scale with the over scroll distance. The
  /// auto-scroll velocity = <distance of overscroll> * velocityScalar.
  final double velocityScalar;

  late Rect _dragTargetRelatedToScrollOrigin;

  /// Whether the auto scroll is in progress.
  bool get scrolling => _scrolling;
  bool _scrolling = false;

  double _offsetExtent(Offset offset, Axis scrollDirection) {
    switch (scrollDirection) {
      case Axis.horizontal:
        return offset.dx;
      case Axis.vertical:
        return offset.dy;
    }
  }

  double _sizeExtent(Size size, Axis scrollDirection) {
    switch (scrollDirection) {
      case Axis.horizontal:
        return size.width;
      case Axis.vertical:
        return size.height;
    }
  }

  AxisDirection get _axisDirection => scrollable.axisDirection;
  Axis get _scrollDirection => axisDirectionToAxis(_axisDirection);

  /// Starts the auto scroll if the [dragTarget] is close to the edge.
  ///
  /// The scroll starts to scroll the [scrollable] if the target rect is close
  /// to the edge of the [scrollable]; otherwise, it remains stationary.
  ///
  /// If the scrollable is already scrolling, calling this method updates the
  /// previous dragTarget to the new value and continues scrolling if necessary.
  void startAutoScrollIfNecessary(Rect dragTarget, {Duration? duration}) {
    final Offset deltaToOrigin = scrollable.deltaToScrollOrigin;
    _dragTargetRelatedToScrollOrigin =
        dragTarget.translate(deltaToOrigin.dx, deltaToOrigin.dy);
    if (_scrolling) {
      // The change will be picked up in the next scroll.
      return;
    }
    assert(!_scrolling);
    _scroll(duration: duration);
  }

  /// Stop any ongoing auto scrolling.
  void stopAutoScroll() {
    _scrolling = false;
  }

  Future<void> _scroll({Duration? duration}) async {
    final RenderBox scrollRenderBox =
        scrollable.context.findRenderObject()! as RenderBox;
    final Rect globalRect = MatrixUtils.transformRect(
      scrollRenderBox.getTransformTo(null),
      Rect.fromLTWH(
        0,
        0,
        scrollRenderBox.size.width,
        scrollRenderBox.size.height,
      ),
    );
    assert(
      globalRect.size.width >= _dragTargetRelatedToScrollOrigin.size.width &&
          globalRect.size.height >=
              _dragTargetRelatedToScrollOrigin.size.height,
      'Drag target size is larger than scrollable size, which may cause bouncing',
    );
    _scrolling = true;
    double? newOffset;
    const double overDragMax = 20.0;

    final Offset deltaToOrigin = scrollable.deltaToScrollOrigin;
    final Offset viewportOrigin =
        globalRect.topLeft.translate(deltaToOrigin.dx, deltaToOrigin.dy);
    final double viewportStart =
        _offsetExtent(viewportOrigin, _scrollDirection);
    final double viewportEnd =
        viewportStart + _sizeExtent(globalRect.size, _scrollDirection);

    final double proxyStart = _offsetExtent(
      _dragTargetRelatedToScrollOrigin.topLeft,
      _scrollDirection,
    );
    final double proxyEnd = _offsetExtent(
      _dragTargetRelatedToScrollOrigin.bottomRight,
      _scrollDirection,
    );
    switch (_axisDirection) {
      case AxisDirection.up:
      case AxisDirection.left:
        if (proxyEnd > viewportEnd &&
            scrollable.position.pixels > scrollable.position.minScrollExtent) {
          final double overDrag = math.min(proxyEnd - viewportEnd, overDragMax);
          newOffset = math.max(
            scrollable.position.minScrollExtent,
            scrollable.position.pixels - overDrag,
          );
        } else if (proxyStart < viewportStart &&
            scrollable.position.pixels < scrollable.position.maxScrollExtent) {
          final double overDrag =
              math.min(viewportStart - proxyStart, overDragMax);
          newOffset = math.min(
            scrollable.position.maxScrollExtent,
            scrollable.position.pixels + overDrag,
          );
        }
      case AxisDirection.right:
      case AxisDirection.down:
        if (proxyStart < viewportStart &&
            scrollable.position.pixels > scrollable.position.minScrollExtent) {
          final double overDrag =
              math.min(viewportStart - proxyStart, overDragMax);
          newOffset = math.max(
            scrollable.position.minScrollExtent,
            scrollable.position.pixels - overDrag,
          );
        } else if (proxyEnd > viewportEnd &&
            scrollable.position.pixels < scrollable.position.maxScrollExtent) {
          final double overDrag = math.min(proxyEnd - viewportEnd, overDragMax);
          newOffset = math.min(
            scrollable.position.maxScrollExtent,
            scrollable.position.pixels + overDrag,
          );
        }
    }

    if (newOffset == null ||
        (newOffset - scrollable.position.pixels).abs() < 1.0) {
      // Drag should not trigger scroll.
      _scrolling = false;
      return;
    }
    duration ??= Duration(milliseconds: (1000 / velocityScalar).round());
    if (duration == Duration.zero) {
      scrollable.position.jumpTo(newOffset);
    } else {
      await scrollable.position.animateTo(
        newOffset,
        duration: duration,
        curve: Curves.linear,
      );
    }

    if (onScrollViewScrolled != null) {
      onScrollViewScrolled!();
    }
    if (_scrolling) {
      await _scroll(duration: duration);
    }
  }
}

/// A typedef for a function that can calculate the offset for a type of scroll
/// increment given a [ScrollIncrementDetails].
///
/// This function is used as the type for [Scrollable.incrementCalculator],
/// which is called from a [ScrollAction].
typedef ScrollIncrementCalculator = double Function(
  ScrollIncrementDetails details,
);

/// An [Action] that scrolls the [Scrollable] that encloses the current
/// [primaryFocus] by the amount configured in the [ScrollIntent] given to it.
///
/// If a Scrollable cannot be found above the current [primaryFocus], the
/// [PrimaryScrollController] will be considered for default handling of
/// [ScrollAction]s.
///
/// If [Scrollable.incrementCalculator] is null for the scrollable, the default
/// for a [ScrollIntent.type] set to [ScrollIncrementType.page] is 80% of the
/// size of the scroll window, and for [ScrollIncrementType.line], 50 logical
/// pixels.
class ScrollAction extends Action<ScrollIntent> {
  @override
  bool isEnabled(ScrollIntent intent) {
    final FocusNode? focus = primaryFocus;
    final bool contextIsValid = focus != null && focus.context != null;
    if (contextIsValid) {
      // Check for primary scrollable within the current context
      if (Scrollable.maybeOf(focus.context!) != null) {
        return true;
      }
      // Check for fallback scrollable with context from PrimaryScrollController
      final ScrollController? primaryScrollController =
          PrimaryScrollController.maybeOf(focus.context!);
      return primaryScrollController != null &&
          primaryScrollController.hasClients;
    }
    return false;
  }

  /// Returns the scroll increment for a single scroll request, for use when
  /// scrolling using a hardware keyboard.
  ///
  /// Must not be called when the position is null, or when any of the position
  /// metrics (pixels, viewportDimension, maxScrollExtent, minScrollExtent) are
  /// null. The type and state arguments must not be null, and the widget must
  /// have already been laid out so that the position fields are valid.
  static double _calculateScrollIncrement(
    ScrollableState state, {
    ScrollIncrementType type = ScrollIncrementType.line,
  }) {
    assert(state.position.hasPixels);
    assert(
      state.resolvedPhysics == null ||
          state.resolvedPhysics!.shouldAcceptUserOffset(state.position),
    );
    if (state.widget.incrementCalculator != null) {
      return state.widget.incrementCalculator!(
        ScrollIncrementDetails(
          type: type,
          metrics: state.position,
        ),
      );
    }
    switch (type) {
      case ScrollIncrementType.line:
        return 50.0;
      case ScrollIncrementType.page:
        return 0.8 * state.position.viewportDimension;
    }
  }

  /// Find out how much of an increment to move by, taking the different
  /// directions into account.
  static double getDirectionalIncrement(
    ScrollableState state,
    ScrollIntent intent,
  ) {
    final double increment =
        _calculateScrollIncrement(state, type: intent.type);
    switch (intent.direction) {
      case AxisDirection.down:
        switch (state.axisDirection) {
          case AxisDirection.up:
            return -increment;
          case AxisDirection.down:
            return increment;
          case AxisDirection.right:
          case AxisDirection.left:
            return 0.0;
        }
      case AxisDirection.up:
        switch (state.axisDirection) {
          case AxisDirection.up:
            return increment;
          case AxisDirection.down:
            return -increment;
          case AxisDirection.right:
          case AxisDirection.left:
            return 0.0;
        }
      case AxisDirection.left:
        switch (state.axisDirection) {
          case AxisDirection.right:
            return -increment;
          case AxisDirection.left:
            return increment;
          case AxisDirection.up:
          case AxisDirection.down:
            return 0.0;
        }
      case AxisDirection.right:
        switch (state.axisDirection) {
          case AxisDirection.right:
            return increment;
          case AxisDirection.left:
            return -increment;
          case AxisDirection.up:
          case AxisDirection.down:
            return 0.0;
        }
    }
  }

  @override
  void invoke(ScrollIntent intent) {
    ScrollableState? state = Scrollable.maybeOf(primaryFocus!.context!);
    if (state == null) {
      final ScrollController primaryScrollController =
          PrimaryScrollController.of(primaryFocus!.context!);
      assert(() {
        if (primaryScrollController.positions.length != 1) {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary(
              'A ScrollAction was invoked with the PrimaryScrollController, but '
              'more than one ScrollPosition is attached.',
            ),
            ErrorDescription(
              'Only one ScrollPosition can be manipulated by a ScrollAction at '
              'a time.',
            ),
            ErrorHint(
              'The PrimaryScrollController can be inherited automatically by '
              'descendant ScrollViews based on the TargetPlatform and scroll '
              'direction. By default, the PrimaryScrollController is '
              'automatically inherited on mobile platforms for vertical '
              'ScrollViews. ScrollView.primary can also override this behavior.',
            ),
          ]);
        }
        return true;
      }());

      if (primaryScrollController.position.context.notificationContext ==
              null &&
          Scrollable.maybeOf(
                primaryScrollController.position.context.notificationContext!,
              ) ==
              null) {
        return;
      }
      state = Scrollable.maybeOf(
        primaryScrollController.position.context.notificationContext!,
      );
    }
    assert(
      state != null,
      '$ScrollAction was invoked on a context that has no scrollable parent',
    );
    assert(
      state!.position.hasPixels,
      'Scrollable must be laid out before it can be scrolled via a ScrollAction',
    );

    // Don't do anything if the user isn't allowed to scroll.
    if (state!.resolvedPhysics != null &&
        !state.resolvedPhysics!.shouldAcceptUserOffset(state.position)) {
      return;
    }
    final double increment = getDirectionalIncrement(state, intent);
    if (increment == 0.0) {
      return;
    }
    state.position.moveTo(
      state.position.pixels + increment,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
  }
}
