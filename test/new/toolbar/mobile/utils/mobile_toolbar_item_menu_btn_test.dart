import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test_helpers/mobile_toolbar_style_test_widget.dart';

void main() {
  testWidgets('MobileToolbarItemMenuBtn should display label and icon',
      (WidgetTester tester) async {
    final onPressed = () {};
    final icon = Icon(Icons.add);
    final label = 'Add';
    final widget = MobileToolbarItemMenuBtn(
      onPressed: onPressed,
      icon: icon,
      label: label,
    );

    await tester.pumpWidget(MobileToolbarStyleTestWidget(
      child: widget,
    ));

    expect(find.byWidget(widget), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
  });
}
