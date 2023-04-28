import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class IconItemWidget extends StatelessWidget {
  const IconItemWidget({
    super.key,
    this.size = const Size.square(32.0),
    required this.iconName,
    required this.isHighlight,
    this.tooltip,
    this.onPressed,
  });

  final Size size;
  final String iconName;
  final bool isHighlight;
  final String? tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    Widget child = FlowySvg(
      name: iconName,
      color: isHighlight ? Colors.lightBlue : null,
    );
    if (onPressed != null) {
      child = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: IconButton(
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          padding: EdgeInsets.zero,
          icon: child,
          iconSize: size.width,
          onPressed: onPressed,
        ),
      );
    }
    if (tooltip != null) {
      child = Tooltip(
        textAlign: TextAlign.center,
        preferBelow: false,
        message: tooltip,
        child: child,
      );
    }
    return SizedBox(
      width: size.width,
      height: size.height,
      child: child,
    );
  }
}
