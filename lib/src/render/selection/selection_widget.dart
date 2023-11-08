import 'package:flutter/material.dart';

class SelectionWidget extends StatefulWidget {
  const SelectionWidget({
    super.key,
    required this.layerLink,
    required this.rect,
    required this.color,
    this.decoration,
  });

  final Color color;
  final Rect rect;
  final LayerLink layerLink;
  final BoxDecoration? decoration;

  @override
  State<SelectionWidget> createState() => _SelectionWidgetState();
}

class _SelectionWidgetState extends State<SelectionWidget> {
  @override
  Widget build(BuildContext context) {
    return Positioned.fromRect(
      rect: widget.rect,
      child: CompositedTransformFollower(
        link: widget.layerLink,
        offset: widget.rect.topLeft,
        showWhenUnlinked: false,
        // Ignore the gestures in selection overlays
        //  to solve the problem that selection areas cannot overlap.
        child: IgnorePointer(
          child: Container(
            color: widget.decoration == null ? widget.color : null,
            decoration: widget.decoration,
          ),
        ),
      ),
    );
  }
}
