import 'package:flutter/material.dart';

import 'toolbar_item.dart';

class ToolbarItemWidget extends StatelessWidget {
  const ToolbarItemWidget({
    Key? key,
    required this.item,
    required this.isHighlight,
    required this.onPressed,
    this.toolbarItemHeight,
    this.toolbarItemWidth,
    required this.toolbarIconSize,
  }) : super(key: key);

  final ToolbarItem item;
  final VoidCallback onPressed;
  final bool isHighlight;
  final double? toolbarItemHeight;
  final double? toolbarItemWidth;
  final double toolbarIconSize;

  @override
  Widget build(BuildContext context) {
    if (item.iconBuilder != null) {
      return SizedBox(
        width: toolbarItemWidth,
        height: toolbarItemHeight,
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
