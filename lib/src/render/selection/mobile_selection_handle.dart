import 'dart:io';

import 'package:appflowy_editor/src/render/selection/mobile_basic_handle.dart';
import 'package:flutter/material.dart';

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

    var adjustedRect = rect;
    if (handleType != HandleType.none) {
      if (Platform.isIOS) {
        // on iOS, the cursor will still be visible if the selection is not collapsed.
        // So, adding a threshold padding to avoid row overflow.
        const threshold = 0.25;
        adjustedRect = Rect.fromLTWH(
          rect.left - 2 * (handleWidth + threshold),
          rect.top - handleBallWidth,
          rect.width + 4 * (handleWidth + threshold),
          rect.height + 2 * handleBallWidth,
        );
      } else if (Platform.isAndroid) {
        // on Android, normally the cursor will be hidden if the selection is not collapsed.
        // Extend the click area to make it easier to click.
        adjustedRect = Rect.fromLTWH(
          rect.left - 2 * (handleBallWidth),
          rect.top,
          rect.width + 4 * (handleBallWidth),
          // Enable clicking in the handle area outside the stack.
          // https://github.com/flutter/flutter/issues/75747
          rect.height + 2 * handleBallWidth,
        );
      }
    }

    return Positioned.fromRect(
      rect: adjustedRect,
      child: CompositedTransformFollower(
        link: layerLink,
        offset: adjustedRect.topLeft,
        showWhenUnlinked: false,
        child: DragHandle(
          handleType: handleType,
          handleColor: handleColor,
          handleHeight: adjustedRect.height,
          handleWidth: handleWidth,
          handleBallWidth: handleBallWidth,
        ),
      ),
    );
  }
}
