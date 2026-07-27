import 'dart:math' as math;

import 'package:appflowy_editor/src/editor/util/platform_extension.dart';
import 'package:appflowy_editor/src/render/selection/mobile_basic_handle.dart';
import 'package:flutter/material.dart';

// Apple HIG / Material minimum recommended touch target. Used to grow the
// handle's hit area without changing the visible ball position, so users can
// grab the drag handle without accidentally tapping the editor below.
const double _kMinIOSTouchTarget = 44.0;
const double _kMinAndroidTouchTarget = 48.0;

class MobileSelectionHandle extends StatelessWidget {
  const MobileSelectionHandle({
    super.key,
    required this.layerLink,
    required this.rect,
    this.handleType = HandleType.none,
    this.handleColor = Colors.black,
    this.handleBallWidth = 6.0,
    this.handleWidth = 2.0,
    this.enableHapticFeedbackOnAndroid = true,
  });

  final Rect rect;
  final LayerLink layerLink;
  final HandleType handleType;
  final Color handleColor;
  final double handleWidth;
  final double handleBallWidth;
  final bool enableHapticFeedbackOnAndroid;

  @override
  Widget build(BuildContext context) {
    assert(handleType != HandleType.collapsed);

    var visualRect = rect;
    if (handleType != HandleType.none) {
      if (PlatformExtension.isIOS) {
        // on iOS, the cursor will still be visible if the selection is not collapsed.
        // So, adding a threshold padding to avoid row overflow.
        const threshold = 0.25;
        visualRect = Rect.fromLTWH(
          rect.left - 2 * (handleWidth + threshold),
          rect.top - handleBallWidth,
          rect.width + 4 * (handleWidth + threshold),
          rect.height + 2 * handleBallWidth,
        );
      } else if (PlatformExtension.isAndroid) {
        // on Android, normally the cursor will be hidden if the selection is not collapsed.
        // Extend the click area to make it easier to click.
        visualRect = Rect.fromLTWH(
          rect.left - 2 * handleBallWidth,
          rect.top,
          rect.width + 4 * handleBallWidth,
          // Enable clicking in the handle area outside the stack.
          // https://github.com/flutter/flutter/issues/75747
          rect.height + 2 * handleBallWidth,
        );
      }
    }

    // Touch zone is grown to meet HIG/Material minimum touch targets, but the
    // visible handle column keeps its original height so the ball stays glued
    // to the text baseline.
    Rect touchRect = visualRect;
    if (handleType != HandleType.none) {
      final minSize = PlatformExtension.isIOS
          ? _kMinIOSTouchTarget
          : _kMinAndroidTouchTarget;
      touchRect = _expandToMinTouchTarget(visualRect, minSize: minSize);
    }

    return Positioned.fromRect(
      rect: touchRect,
      child: CompositedTransformFollower(
        link: layerLink,
        offset: touchRect.topLeft,
        showWhenUnlinked: false,
        child: DragHandle(
          handleType: handleType,
          handleColor: handleColor,
          handleHeight: visualRect.height,
          handleWidth: handleWidth,
          handleBallWidth: handleBallWidth,
        ),
      ),
    );
  }

  /// Pads [r] outward so that both axes are at least [minSize], anchoring the
  /// expansion away from the visible handle ball so the ball stays put on
  /// screen. For the left handle the ball sits at the left of [r], so we grow
  /// to the right; for the right handle we grow to the left. We always grow
  /// downward, since the ball lives below the text baseline.
  Rect _expandToMinTouchTarget(Rect r, {required double minSize}) {
    final extraW = math.max(0.0, minSize - r.width);
    final extraH = math.max(0.0, minSize - r.height);
    if (extraW == 0 && extraH == 0) return r;

    double left = r.left;
    double width = r.width;
    if (extraW > 0) {
      if (handleType == HandleType.left) {
        // Ball is at r.left, grow rightward.
        width += extraW;
      } else {
        // Ball is at r.right, grow leftward.
        left -= extraW;
        width += extraW;
      }
    }

    return Rect.fromLTWH(left, r.top, width, r.height + extraH);
  }
}
