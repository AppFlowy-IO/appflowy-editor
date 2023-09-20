import 'package:flutter/material.dart';

class MobileSelectionWidget extends StatelessWidget {
  const MobileSelectionWidget({
    Key? key,
    required this.layerLink,
    required this.rect,
    required this.color,
    this.decoration,
    this.showLeftHandler = false,
    this.showRightHandler = false,
    this.handlerColor = Colors.black,
  }) : super(key: key);

  final Color color;
  final Rect rect;
  final LayerLink layerLink;
  final BoxDecoration? decoration;
  final bool showLeftHandler;
  final bool showRightHandler;
  final Color handlerColor;

  @override
  Widget build(BuildContext context) {
    const handlerWidth = 2.0;
    const handlerBallWidth = 6.0;
    // left and right add 2px to avoid the selection area from being too narrow
    var adjustedRect = rect;
    if (showLeftHandler || showRightHandler) {
      adjustedRect = Rect.fromLTWH(
        rect.left - 2 * handlerWidth,
        rect.top - handlerBallWidth,
        rect.width + 4 * handlerWidth,
        rect.height + 2 * handlerBallWidth,
      );
    }
    return Positioned.fromRect(
      rect: adjustedRect,
      child: CompositedTransformFollower(
        link: layerLink,
        offset: adjustedRect.topLeft,
        showWhenUnlinked: false,
        // Ignore the gestures in selection overlays
        //  to solve the problem that selection areas cannot overlap.
        child: IgnorePointer(
          child: MobileSelectionWithHandler(
            color: color,
            decoration: decoration,
            showLeftHandler: showLeftHandler,
            showRightHandler: showRightHandler,
            handlerColor: handlerColor,
            handlerHeight: adjustedRect.height,
            handlerWidth: handlerWidth,
            handlerBallWidth: handlerBallWidth,
          ),
        ),
      ),
    );
  }
}

class MobileSelectionWithHandler extends StatelessWidget {
  const MobileSelectionWithHandler({
    super.key,
    required this.color,
    this.showLeftHandler = false,
    this.showRightHandler = false,
    this.handlerColor = Colors.black,
    this.decoration,
    this.handlerWidth = 2.0,
    required this.handlerHeight,
    required this.handlerBallWidth,
  });

  final Color color;
  final BoxDecoration? decoration;

  final bool showLeftHandler;
  final bool showRightHandler;
  final Color handlerColor;
  final double handlerWidth;
  final double handlerHeight;
  final double handlerBallWidth;

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      color: decoration == null ? color : null,
      decoration: decoration,
    );
    if (showLeftHandler || showRightHandler) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLeftHandler)
            _DragHandler(
              handlerColor: handlerColor,
              handlerWidth: handlerWidth,
              handlerBallWidth: handlerBallWidth,
              handlerHeight: handlerHeight,
              showLeftHandler: true,
              showRightHandler: false,
            ),
          Expanded(child: child),
          if (showRightHandler)
            _DragHandler(
              handlerColor: handlerColor,
              handlerWidth: handlerWidth,
              handlerBallWidth: handlerBallWidth,
              handlerHeight: handlerHeight,
              showRightHandler: true,
              showLeftHandler: false,
            ),
        ],
      );
    }
    return child;
  }
}

class _DragHandler extends StatelessWidget {
  const _DragHandler({
    required this.handlerHeight,
    this.handlerColor = Colors.black,
    this.handlerWidth = 2.0,
    this.handlerBallWidth = 6.0,
    this.showLeftHandler = false,
    this.showRightHandler = false,
  });

  final Color handlerColor;
  final double handlerWidth;
  final double handlerHeight;
  final double handlerBallWidth;
  final bool showLeftHandler;
  final bool showRightHandler;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        if (showLeftHandler)
          Container(
            width: handlerBallWidth,
            height: handlerBallWidth,
            decoration: BoxDecoration(
              color: handlerColor,
              shape: BoxShape.circle,
            ),
          ),
        if (showRightHandler)
          SizedBox(
            width: handlerBallWidth,
            height: handlerBallWidth,
          ),
        Container(
          width: handlerWidth,
          color: handlerColor,
          height: handlerHeight - 2.0 * handlerBallWidth,
        ),
        if (showRightHandler)
          Container(
            width: handlerBallWidth,
            height: handlerBallWidth,
            decoration: BoxDecoration(
              color: handlerColor,
              shape: BoxShape.circle,
            ),
          ),
        if (showLeftHandler)
          SizedBox(
            width: handlerBallWidth,
            height: handlerBallWidth,
          ),
      ],
    );
  }
}
