import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/infra/flowy_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_helper.dart';

void main() {
  group('ActionMenuItem tests', () {
    testWidgets('ActionMenuItem.icon()', (tester) async {
      int count = 0;

      final item = ActionMenuItem.icon(
        iconData: Icons.abc,
        onPressed: () => count++,
      );

      await tester.buildAndPump(item.iconBuilder());
      await tester.pumpAndSettle();

      item.onPressed!.call();
      expect(count, 1);

      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('ActionMenuItem.svg()', (tester) async {
      final item = ActionMenuItem.svg(name: 'check', onPressed: () {});

      await tester.buildAndPump(item.iconBuilder());
      await tester.pumpAndSettle();

      expect(find.byType(FlowySvg), findsOneWidget);
    });

    testWidgets('ActionMenuItem.separator()', (tester) async {
      final item = ActionMenuItem.separator();

      await tester.buildAndPump(item.iconBuilder());
      await tester.pumpAndSettle();

      expect(find.byType(FlowySvg), findsOneWidget);

      final svg = tester.widget<FlowySvg>(find.byType(FlowySvg));
      expect(svg.name, 'image_toolbar/divider');
    });
  });
}
