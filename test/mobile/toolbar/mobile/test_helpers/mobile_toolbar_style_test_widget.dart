import 'package:flutter/material.dart';
import 'package:appflowy_editor/appflowy_editor.dart';

/// Used in testing mobile app with toolbar
class MobileToolbarStyleTestWidget extends StatelessWidget {
  const MobileToolbarStyleTestWidget({
    required this.child,
    super.key,
    this.backgroundColor = Colors.white,
    this.foregroundColor = const Color(0xff676666),
    this.clearDiagonalLineColor = const Color(0xffB3261E),
    this.itemHighlightColor = const Color(0xff1F71AC),
    this.itemOutlineColor = const Color(0xFFE3E3E3),
    this.tabbarSelectedBackgroundColor = const Color(0x23808080),
    this.tabbarSelectedForegroundColor = Colors.black,
    this.toolbarHeight = 50.0,
    this.borderRadius = 6.0,
    this.buttonHeight = 40,
    this.buttonSpacing = 8,
    this.buttonBorderWidth = 1,
    this.buttonSelectedBorderWidth = 2,
    this.textColorOptions = const [
      ColorOption(
        colorHex: '#808080',
        name: 'Gray',
      ),
      ColorOption(
        colorHex: '#A52A2A',
        name: 'Brown',
      ),
      ColorOption(
        colorHex: '#FFFF00',
        name: 'Yellow',
      ),
      ColorOption(
        colorHex: '#008000',
        name: 'Green',
      ),
      ColorOption(
        colorHex: '#0000FF',
        name: 'Blue',
      ),
      ColorOption(
        colorHex: '#800080',
        name: 'Purple',
      ),
      ColorOption(
        colorHex: '#FFC0CB',
        name: 'Pink',
      ),
      ColorOption(
        colorHex: '#FF0000',
        name: 'Red',
      ),
    ],
    this.backgroundColorOptions = const [
      ColorOption(
        colorHex: '#4d4d4d',
        name: 'Gray',
      ),
      ColorOption(
        colorHex: '#a52a2a',
        name: 'Brown',
      ),
      ColorOption(
        colorHex: '#ffff00',
        name: 'Yellow',
      ),
      ColorOption(
        colorHex: '#008000',
        name: 'Green',
      ),
      ColorOption(
        colorHex: '#0000ff',
        name: 'Blue',
      ),
      ColorOption(
        colorHex: '#800080',
        name: 'Purple',
      ),
      ColorOption(
        colorHex: '#ffc0cb',
        name: 'Pink',
      ),
      ColorOption(
        colorHex: '#ff0000',
        name: 'Red',
      ),
    ],
  });
  final Widget child;

  final Color backgroundColor;
  final Color foregroundColor;
  final Color clearDiagonalLineColor;
  final Color itemHighlightColor;
  final Color itemOutlineColor;
  final Color tabbarSelectedBackgroundColor;
  final Color tabbarSelectedForegroundColor;
  final double toolbarHeight;
  final double borderRadius;
  final double buttonHeight;
  final double buttonSpacing;
  final double buttonBorderWidth;
  final double buttonSelectedBorderWidth;
  final List<ColorOption> textColorOptions;
  final List<ColorOption> backgroundColorOptions;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MobileToolbarStyle(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        clearDiagonalLineColor: clearDiagonalLineColor,
        itemHighlightColor: itemHighlightColor,
        itemOutlineColor: itemOutlineColor,
        tabbarSelectedBackgroundColor: tabbarSelectedBackgroundColor,
        tabbarSelectedForegroundColor: tabbarSelectedForegroundColor,
        toolbarHeight: toolbarHeight,
        borderRadius: borderRadius,
        buttonHeight: buttonHeight,
        buttonSpacing: buttonSpacing,
        buttonBorderWidth: buttonBorderWidth,
        buttonSelectedBorderWidth: buttonSelectedBorderWidth,
        textColorOptions: textColorOptions,
        backgroundColorOptions: backgroundColorOptions,
        child: child,
      ),
    );
  }
}
