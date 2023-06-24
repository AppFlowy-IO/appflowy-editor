import 'package:flutter/material.dart';

/// Style for the mobile toolbar.
///
/// foregroundColor -> text and icon color
///
/// itemHighlightColor -> selected item border color
///
/// itemOutlineColor -> item border color
class MobileToolbarStyle extends InheritedWidget {
  final Color backgroundColor;
  final Color foregroundColor;
  final Color itemHighlightColor;
  final Color itemOutlineColor;
  final double toolbarHeight;
  final double borderRadius;

  const MobileToolbarStyle({
    super.key,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.itemHighlightColor,
    required this.itemOutlineColor,
    required this.toolbarHeight,
    required this.borderRadius,
    required Widget child,
  }) : super(child: child);

  static MobileToolbarStyle of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MobileToolbarStyle>()!;
  }

  @override
  bool updateShouldNotify(covariant MobileToolbarStyle oldWidget) {
    // This function is called whenever the inherited widget is rebuilt.
    // It should return true if the new widget's values are different from the old widget's values.
    return backgroundColor != oldWidget.backgroundColor ||
        foregroundColor != oldWidget.foregroundColor ||
        itemHighlightColor != oldWidget.itemHighlightColor ||
        itemOutlineColor != oldWidget.itemOutlineColor ||
        toolbarHeight != oldWidget.toolbarHeight ||
        borderRadius != oldWidget.borderRadius;
  }
}
