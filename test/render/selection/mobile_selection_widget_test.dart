import 'package:appflowy_editor/src/core/document/node.dart';
import 'package:appflowy_editor/src/render/selection/mobile_selection_handle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_helper.dart';

void main() {
  group('MobileSelectionWidget', () {
    testWidgets('can render', (tester) async {
      final node = Node(type: 'paragraph');

      await tester.buildAndPump(
        Stack(
          children: [
            MobileSelectionArea(
              layerLink: node.layerLink,
              rect: const Rect.fromLTWH(0, 0, 100, 100),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MobileSelectionArea), findsOneWidget);
    });
  });
}
