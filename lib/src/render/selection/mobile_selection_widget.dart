import 'package:flutter/material.dart';

class MobileSelectionWidget extends StatefulWidget {
  const MobileSelectionWidget({
    Key? key,
    required this.layerLink,
    required this.rect,
    required this.color,
    required this.cursorColor,
    required this.showEndCursor,
    required this.showStartCursor,
    this.decoration,
  }) : super(key: key);

  final Color color;
  final Color cursorColor;
  final bool showEndCursor;
  final bool showStartCursor;
  final Rect rect;
  final LayerLink layerLink;
  final BoxDecoration? decoration;

  @override
  State<MobileSelectionWidget> createState() => _MobileSelectionWidgetState();
}

class _MobileSelectionWidgetState extends State<MobileSelectionWidget> {
  @override
  Widget build(BuildContext context) {
    return Positioned.fromRect(
      rect: widget.rect,
      child: CompositedTransformFollower(
        link: widget.layerLink,
        offset: widget.rect.topLeft,
        showWhenUnlinked: true,
        // Ignore the gestures in selection overlays
        //  to solve the problem that selection areas cannot overlap.
        child: IgnorePointer(
          child: Row(
            children: [
              widget.showStartCursor
                  ? Container(
                      height: 30,
                      color: widget.cursorColor,
                      width: 1,
                    )
                  : Container(),
              Expanded(
                child: Container(
                  color: widget.decoration == null ? widget.color : null,
                  decoration: widget.decoration,
                ),
              ),
                            widget.showEndCursor
                  ? Container(
                      height: 30,
                      color: widget.cursorColor,
                      width: 1,
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
