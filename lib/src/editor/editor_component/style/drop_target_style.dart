import 'package:flutter/material.dart';

/// Style for the Drop target which is rendered in the [AppFlowyEditor]
/// using the [DesktopSelectionService] specifically the [renderDropTargetForOffset] method.
///
class AppFlowyDropTargetStyle {
  const AppFlowyDropTargetStyle({
    this.margin,
    this.constraints = const BoxConstraints(),
    this.color,
    this.borderRadius = 8,
    this.height = 2,
  });

  /// The margin to apply to the drop target.
  ///
  /// Useful if you want to add some padding around the drop target.
  ///
  final EdgeInsets? margin;

  /// Constraints of the drop target
  ///
  /// Defaults to default [BoxConstraints]
  ///
  final BoxConstraints constraints;

  /// The color of the drop target (horizontal line)
  ///
  /// Defaults to [ThemeData.colorScheme.primary]
  ///
  final Color? color;

  /// Defaults to 8
  ///
  final double borderRadius;

  /// Defaults to 2
  ///
  final double height;
}
