import 'package:flutter/material.dart';

import 'toolbar_item.dart';

class ToolbarItemWidget extends StatelessWidget {
  const ToolbarItemWidget({
    Key? key,
    required this.item,
    required this.isHighlight,
    required this.onPressed,
    required this.toolbarIconSize,
    this.toolbarItemWidth,
    this.toolbarItemHeight,
  }) : super(key: key);

  final ToolbarItem item;
  final VoidCallback onPressed;
  final double toolbarIconSize;
  final double? toolbarItemWidth;
  final double? toolbarItemHeight;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    if (item.iconBuilder != null) {
      return SizedBox(
        width: toolbarItemHeight,
        height: toolbarItemWidth,
        child: Tooltip(
          textAlign: TextAlign.center,
          preferBelow: false,
          message: item.tooltipsMessage,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: IconButton(
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              padding: EdgeInsets.zero,
              icon: item.iconBuilder!(isHighlight),
              iconSize: toolbarIconSize,
              onPressed: onPressed,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
