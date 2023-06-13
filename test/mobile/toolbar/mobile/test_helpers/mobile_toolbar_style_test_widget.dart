import 'package:flutter/material.dart';
import 'package:appflowy_editor/appflowy_editor.dart';

/// Used in testing mobile app with toolbar
class MobileToolbarStyleTestWidget extends StatelessWidget {
  const MobileToolbarStyleTestWidget({
    required this.child,
    super.key,
    this.backgroundColor = Colors.white,
    this.foregroundColor = Colors.black,
    this.itemHighlightColor = Colors.blue,
    this.itemOutlineColor = Colors.grey,
    this.toolbarHeight = 50.0,
    this.borderRadius = 10.0,
  });
  final Widget child;

  final Color backgroundColor;
  final Color foregroundColor;
  final Color itemHighlightColor;
  final Color itemOutlineColor;
  final double toolbarHeight;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MobileToolbarStyle(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        itemHighlightColor: itemHighlightColor,
        itemOutlineColor: itemOutlineColor,
        toolbarHeight: toolbarHeight,
        borderRadius: borderRadius,
        child: child,
      ),
    );
  }
}
