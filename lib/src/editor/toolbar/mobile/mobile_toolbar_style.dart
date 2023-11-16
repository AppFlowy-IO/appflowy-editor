import 'package:flutter/material.dart';

/// Style for the mobile toolbar.
///
/// foregroundColor -> text and icon color
///
/// itemHighlightColor -> selected item border color
///
/// itemOutlineColor -> item border color
class MobileToolbarTheme extends InheritedWidget {
  const MobileToolbarTheme({
    super.key,
    this.backgroundColor = Colors.white,
    this.foregroundColor = const Color(0xff676666),
    this.clearDiagonalLineColor = const Color(0xffB3261E),
    this.itemHighlightColor = const Color(0xff1F71AC),
    this.itemOutlineColor = const Color(0xFFE3E3E3),
    this.tabBarSelectedBackgroundColor = const Color(0x23808080),
    this.tabBarSelectedForegroundColor = Colors.black,
    this.primaryColor = const Color(0xff1F71AC),
    this.onPrimaryColor = Colors.white,
    this.outlineColor = const Color(0xFFE3E3E3),
    this.toolbarHeight = 48.0,
    this.borderRadius = 6.0,
    this.buttonHeight = 40.0,
    this.buttonSpacing = 8.0,
    this.buttonBorderWidth = 1.0,
    this.buttonSelectedBorderWidth = 2.0,
    required super.child,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final Color clearDiagonalLineColor;
  final Color itemHighlightColor;
  final Color itemOutlineColor;
  final Color tabBarSelectedBackgroundColor;
  final Color tabBarSelectedForegroundColor;
  final Color primaryColor;
  final Color onPrimaryColor;
  final Color outlineColor;
  final double toolbarHeight;
  final double borderRadius;
  final double buttonHeight;
  final double buttonSpacing;
  final double buttonBorderWidth;
  final double buttonSelectedBorderWidth;

  static MobileToolbarTheme of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MobileToolbarTheme>()!;
  }

  static MobileToolbarTheme? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MobileToolbarTheme>();
  }

  @override
  bool updateShouldNotify(covariant MobileToolbarTheme oldWidget) {
    return backgroundColor != oldWidget.backgroundColor ||
        foregroundColor != oldWidget.foregroundColor ||
        clearDiagonalLineColor != oldWidget.clearDiagonalLineColor ||
        itemHighlightColor != oldWidget.itemHighlightColor ||
        itemOutlineColor != oldWidget.itemOutlineColor ||
        tabBarSelectedBackgroundColor !=
            oldWidget.tabBarSelectedBackgroundColor ||
        tabBarSelectedForegroundColor !=
            oldWidget.tabBarSelectedForegroundColor ||
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
