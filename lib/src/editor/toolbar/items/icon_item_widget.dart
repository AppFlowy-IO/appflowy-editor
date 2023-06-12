import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class SVGIconItemWidget extends StatelessWidget {
  const SVGIconItemWidget({
    super.key,
    this.size = const Size.square(30.0),
    this.iconSize = const Size.square(18.0),
    required this.isHighlight,
    required this.iconName,
    this.tooltip,
    this.onPressed,
  });

  final String iconName;
  final bool isHighlight;
  final Size iconSize;
  final Size size;
  final String? tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconItemWidget(
      tooltip: tooltip,
      onPressed: onPressed,
      size: size,
      icon: FlowySvg(
        name: iconName,
        color: isHighlight ? Colors.lightBlue : null,
        width: iconSize.width,
        height: iconSize.height,
      ),
    );
  }
}

class MaterialIconItemWidget extends StatelessWidget {
  const MaterialIconItemWidget({
    super.key,
    this.size = const Size.square(30.0),
    this.iconSize = const Size.square(18.0),
    required this.isHighlight,
    required this.icon,
    this.tooltip,
    this.onPressed,
  });

  final IconData icon;
  final bool isHighlight;
  final Size iconSize;
  final Size size;
  final String? tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconItemWidget(
      tooltip: tooltip,
      onPressed: onPressed,
      size: size,
      icon: Icon(
        icon,
        color: isHighlight ? Colors.lightBlue : Colors.white,
        size: iconSize.width,
      ),
    );
  }
}

class IconItemWidget extends StatelessWidget {
  const IconItemWidget({
    super.key,
    this.size = const Size.square(30.0),
    required this.icon,
    this.tooltip,
    this.onPressed,
  });

  final Size size;
  final Widget icon;
  final String? tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    Widget child = icon;
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
