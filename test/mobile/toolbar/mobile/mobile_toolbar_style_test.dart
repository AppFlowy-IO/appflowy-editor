import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:appflowy_editor/src/editor/toolbar/mobile/mobile_toolbar_style.dart';

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
    const primaryColor = Color(0xff1F71AC);
    const onPrimaryColor = Colors.white;
    const outlineColor = Color(0xFFE3E3E3);
    const toolbarHeight = 50.0;
    const borderRadius = 6.0;
    const buttonHeight = 40.0;
    const buttonSpacing = 8.0;
    const buttonBorderWidth = 1.0;
    const buttonSelectedBorderWidth = 2.0;

    await tester.pumpWidget(
      const MobileToolbarStyle(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        clearDiagonalLineColor: clearDiagonalLineColor,
        itemHighlightColor: itemHighlightColor,
        itemOutlineColor: itemOutlineColor,
        tabbarSelectedBackgroundColor: tabbarSelectedBackgroundColor,
        tabbarSelectedForegroundColor: tabbarSelectedForegroundColor,
        primaryColor: primaryColor,
        onPrimaryColor: onPrimaryColor,
        outlineColor: outlineColor,
        toolbarHeight: toolbarHeight,
        borderRadius: borderRadius,
        buttonHeight: buttonHeight,
        buttonSpacing: buttonSpacing,
        buttonBorderWidth: buttonBorderWidth,
        buttonSelectedBorderWidth: buttonSelectedBorderWidth,
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
