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
    return Positioned.fromRect(
      rect: rect,
      child: CompositedTransformFollower(
        link: layerLink,
        offset: rect.topLeft,
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
  });

  final Color color;
  final BoxDecoration? decoration;

  final bool showLeftHandler;
  final bool showRightHandler;
  final Color handlerColor;
  final double handlerWidth;

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      color: decoration == null ? color : null,
      decoration: decoration,
    );
    if (showLeftHandler || showRightHandler) {
      child = Row(
        children: [
          if (showLeftHandler)
            Container(
              width: handlerWidth,
              color: handlerColor,
            ),
          Expanded(child: child),
          if (showRightHandler)
            Container(
              width: handlerWidth,
              color: handlerColor,
            ),
        ],
      );
    }
    return child;
  }
}
