import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:appflowy_editor/src/editor/toolbar/mobile/mobile_toolbar_style.dart';
import 'package:appflowy_editor/src/editor/toolbar/utils/utils.dart';

void main() {
  testWidgets('MobileToolbarStyle should have correct values',
      (WidgetTester tester) async {
    const backgroundColor = Colors.white;
    const foregroundColor = Colors.black;
    const clearDiagonalLineColor = Color(0xffB3261E);
    const itemHighlightColor = Color(0xff1F71AC);
    const itemOutlineColor = Color(0xFFE3E3E3);
    const tabbarSelectedBackgroundColor = Color(0x23808080);
    const tabbarSelectedForegroundColor = Colors.black;
    const toolbarHeight = 50.0;
    const borderRadius = 6.0;
    const buttonHeight = 40.0;
    const buttonSpacing = 8.0;
    const buttonBorderWidth = 1.0;
    const buttonSelectedBorderWidth = 2.0;
    const textColorOptions = [
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
    ];
    const backgroundColorOptions = [
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
    ];

    await tester.pumpWidget(
      const MobileToolbarStyle(
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
        child: SizedBox(),
      ),
    );

    final mobileToolbarStyle =
        MobileToolbarStyle.of(tester.element(find.byType(MobileToolbarStyle)));

    expect(mobileToolbarStyle.backgroundColor, equals(backgroundColor));
    expect(mobileToolbarStyle.foregroundColor, equals(foregroundColor));
    expect(mobileToolbarStyle.itemHighlightColor, equals(itemHighlightColor));
    expect(mobileToolbarStyle.itemOutlineColor, equals(itemOutlineColor));
    expect(mobileToolbarStyle.toolbarHeight, equals(toolbarHeight));
    expect(mobileToolbarStyle.borderRadius, equals(borderRadius));
  });
}
