import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:appflowy_editor/src/editor/toolbar/mobile/mobile_toolbar_style.dart';

void main() {
  testWidgets('MobileToolbarStyle should have correct values',
      (WidgetTester tester) async {
    const backgroundColor = Colors.white;
    const foregroundColor = Colors.black;
    const itemHighlightColor = Colors.blue;
    const itemOutlineColor = Colors.grey;
    const toolbarHeight = 50.0;
    const borderRadius = 10.0;

    await tester.pumpWidget(
      MobileToolbarStyle(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        itemHighlightColor: itemHighlightColor,
        itemOutlineColor: itemOutlineColor,
        toolbarHeight: toolbarHeight,
        borderRadius: borderRadius,
        child: const SizedBox(),
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
