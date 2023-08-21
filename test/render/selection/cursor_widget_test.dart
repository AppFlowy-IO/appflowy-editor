import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/render/selection/cursor_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_helper.dart';

void main() {
  group('CursorWidget', () {
    testWidgets('can render verticalLine', (tester) async {
      final node = Node(type: 'paragraph');
      await tester.buildAndPump(
        Stack(
          children: [
            CursorWidget(
              layerLink: node.layerLink,
              rect: const Rect.fromLTWH(0, 0, 50, 50),
              color: Colors.blue,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CursorWidget), findsOneWidget);
    });

    testWidgets('can render borderLine', (tester) async {
      final node = Node(type: 'paragraph');
      await tester.buildAndPump(
        Stack(
          children: [
            CursorWidget(
              cursorStyle: CursorStyle.borderLine,
              layerLink: node.layerLink,
              rect: const Rect.fromLTWH(0, 0, 50, 50),
              color: Colors.blue,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CursorWidget), findsOneWidget);
    });

    testWidgets('can render cover', (tester) async {
      final node = Node(type: 'paragraph');
      await tester.buildAndPump(
        Stack(
          children: [
            CursorWidget(
              cursorStyle: CursorStyle.cover,
              layerLink: node.layerLink,
              rect: const Rect.fromLTWH(0, 0, 50, 50),
              color: Colors.blue,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CursorWidget), findsOneWidget);
    });
  });
}
