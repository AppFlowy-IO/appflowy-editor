import 'dart:io';

import 'package:appflowy_editor/src/render/selection/mobile_basic_handle.dart';
import 'package:flutter/material.dart';

class MobileCollapsedHandle extends StatelessWidget {
  const MobileCollapsedHandle({
    super.key,
    required this.layerLink,
    required this.rect,
    this.handleColor = Colors.black,
    this.handleBallWidth = 6.0,
    this.handleWidth = 2.0,
    this.enableHapticFeedbackOnAndroid = true,
  });

  final Rect rect;
  final LayerLink layerLink;
  final Color handleColor;
  final double handleWidth;
  final double handleBallWidth;
  final bool enableHapticFeedbackOnAndroid;

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return _IOSCollapsedHandle(
        layerLink: layerLink,
        rect: rect,
        handleWidth: handleWidth,
      );
    } else if (Platform.isAndroid) {
      return _AndroidCollapsedHandle(
        layerLink: layerLink,
        rect: rect,
        handleColor: handleColor,
        handleWidth: handleWidth,
        handleBallWidth: handleBallWidth,
        enableHapticFeedbackOnAndroid: enableHapticFeedbackOnAndroid,
      );
    }
    throw UnsupportedError('Unsupported platform');
  }
}

class _IOSCollapsedHandle extends StatelessWidget {
  const _IOSCollapsedHandle({
    required this.layerLink,
    required this.rect,
    this.handleWidth = 2.0,
  });

  final Rect rect;
  final LayerLink layerLink;
  final double handleWidth;

  @override
  Widget build(BuildContext context) {
    // Extend the click area to make it easier to click.
    const extend = 10.0;
    final adjustedRect = Rect.fromLTWH(
      rect.left - extend,
      rect.top - extend,
      rect.width + 2 * extend,
      rect.height + 2 * extend,
    );
    return Positioned.fromRect(
      rect: adjustedRect,
      child: CompositedTransformFollower(
        link: layerLink,
        offset: adjustedRect.topLeft,
        showWhenUnlinked: false,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              child: DragHandle(
                handleHeight: adjustedRect.height,
                handleType: HandleType.collapsed,
                handleColor: Colors.transparent,
                handleWidth: adjustedRect.width,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AndroidCollapsedHandle extends StatelessWidget {
  const _AndroidCollapsedHandle({
    required this.layerLink,
    required this.rect,
    this.handleColor = Colors.black,
    this.handleBallWidth = 6.0,
    this.handleWidth = 2.0,
    this.enableHapticFeedbackOnAndroid = true,
  });

  final Rect rect;
  final LayerLink layerLink;
  final Color handleColor;
  final double handleWidth;
  final double handleBallWidth;
  final bool enableHapticFeedbackOnAndroid;

  @override
  Widget build(BuildContext context) {
    // Extend the click area to make it easier to click.
    final adjustedRect = Rect.fromLTWH(
      rect.left - 2 * (handleBallWidth),
      rect.top,
      rect.width + 4 * (handleBallWidth),
      // Enable clicking in the handle area outside the stack.
      // https://github.com/flutter/flutter/issues/75747
      rect.height + 2 * handleBallWidth,
    );
    return Positioned.fromRect(
      rect: adjustedRect,
      child: CompositedTransformFollower(
        link: layerLink,
        offset: adjustedRect.topLeft,
        showWhenUnlinked: false,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 4.0,
              child: DragHandle(
                handleHeight: adjustedRect.height,
                handleType: HandleType.collapsed,
                handleColor: handleColor,
                handleWidth: adjustedRect.width,
                handleBallWidth: handleBallWidth,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
