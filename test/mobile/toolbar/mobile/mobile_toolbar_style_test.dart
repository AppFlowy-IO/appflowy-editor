import 'package:appflowy_editor/src/editor/toolbar/mobile/mobile_toolbar_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MobileToolbarStyle should have correct values',
      (WidgetTester tester) async {
    const backgroundColor = Colors.white;
    const foregroundColor = Colors.black;
    const itemHighlightColor = Color(0xff1F71AC);
    const itemOutlineColor = Color(0xFFE3E3E3);
    const toolbarHeight = 50.0;
    const borderRadius = 6.0;

    await tester.pumpWidget(
      const MobileToolbarTheme(
        foregroundColor: foregroundColor,
        toolbarHeight: toolbarHeight,
        child: SizedBox(),
      ),
    );

    final mobileToolbarStyle =
        MobileToolbarTheme.of(tester.element(find.byType(MobileToolbarTheme)));

    expect(mobileToolbarStyle.backgroundColor, equals(backgroundColor));
    expect(mobileToolbarStyle.foregroundColor, equals(foregroundColor));
    expect(mobileToolbarStyle.itemHighlightColor, equals(itemHighlightColor));
    expect(mobileToolbarStyle.itemOutlineColor, equals(itemOutlineColor));
    expect(mobileToolbarStyle.toolbarHeight, equals(toolbarHeight));
    expect(mobileToolbarStyle.borderRadius, equals(borderRadius));
  });
}
