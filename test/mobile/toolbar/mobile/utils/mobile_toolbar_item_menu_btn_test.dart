import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test_helpers/mobile_toolbar_style_test_widget.dart';

void main() {
  testWidgets('MobileToolbarItemMenuBtn should display label and icon',
      (WidgetTester tester) async {
    const icon = Icon(Icons.add);
    const label = 'Add';

    await tester.pumpWidget(
      Material(
        child: MobileToolbarStyleTestWidget(
          child: MobileToolbarItemMenuBtn(
            onPressed: () {},
            icon: icon,
            label: const Text(label),
            isSelected: false,
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
  });
}
