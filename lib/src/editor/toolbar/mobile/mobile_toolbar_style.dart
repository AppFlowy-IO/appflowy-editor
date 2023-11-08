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
  final Color clearDiagonalLineColor;
  final Color itemHighlightColor;
  final Color itemOutlineColor;
  final Color tabbarSelectedBackgroundColor;
  final Color tabbarSelectedForegroundColor;
  final Color primaryColor;
  final Color onPrimaryColor;
  final Color outlineColor;
  final double toolbarHeight;
  final double borderRadius;
  final double buttonHeight;
  final double buttonSpacing;
  final double buttonBorderWidth;
  final double buttonSelectedBorderWidth;

  const MobileToolbarStyle({
    super.key,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.clearDiagonalLineColor,
    required this.itemHighlightColor,
    required this.itemOutlineColor,
    required this.tabbarSelectedBackgroundColor,
    required this.tabbarSelectedForegroundColor,
    required this.primaryColor,
    required this.onPrimaryColor,
    required this.outlineColor,
    required this.toolbarHeight,
    required this.borderRadius,
    required this.buttonHeight,
    required this.buttonSpacing,
    required this.buttonBorderWidth,
    required this.buttonSelectedBorderWidth,
    required super.child,
  });

  static MobileToolbarStyle of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MobileToolbarStyle>()!;
  }

  @override
  bool updateShouldNotify(covariant MobileToolbarStyle oldWidget) {
    // This function is called whenever the inherited widget is rebuilt.
    // It should return true if the new widget's values are different from the old widget's values.
    return backgroundColor != oldWidget.backgroundColor ||
        foregroundColor != oldWidget.foregroundColor ||
        clearDiagonalLineColor != oldWidget.clearDiagonalLineColor ||
        itemHighlightColor != oldWidget.itemHighlightColor ||
        itemOutlineColor != oldWidget.itemOutlineColor ||
        tabbarSelectedBackgroundColor !=
            oldWidget.tabbarSelectedBackgroundColor ||
        tabbarSelectedForegroundColor !=
            oldWidget.tabbarSelectedForegroundColor ||
        primaryColor != oldWidget.primaryColor ||
        onPrimaryColor != oldWidget.onPrimaryColor ||
        outlineColor != oldWidget.outlineColor ||
        toolbarHeight != oldWidget.toolbarHeight ||
        borderRadius != oldWidget.borderRadius ||
        buttonHeight != oldWidget.buttonHeight ||
        buttonSpacing != oldWidget.buttonSpacing ||
        buttonBorderWidth != oldWidget.buttonBorderWidth ||
        buttonSelectedBorderWidth != oldWidget.buttonSelectedBorderWidth;
  }
}
