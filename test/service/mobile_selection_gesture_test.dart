import 'package:appflowy_editor/src/service/selection/mobile_selection_gesture.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helper.dart';

void main() {
  group('MobileSelectionGestureDetector', () {
    testWidgets('can render', (tester) async {
      await tester.buildAndPump(const MobileSelectionGestureDetector());
      await tester.pumpAndSettle();

      expect(find.byType(MobileSelectionGestureDetector), findsOneWidget);
    });

    testWidgets('on tap gesture', (tester) async {
      bool onTapDown = false;

      await tester.buildAndPump(
        MobileSelectionGestureDetector(
          onTapUp: (_) => onTapDown = true,
          child: const SizedBox.square(dimension: 50),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SizedBox), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(onTapDown, true);
    });

    testWidgets('on double tap gesture', (tester) async {
      bool onDoubleTapDown = false;

      await tester.buildAndPump(
        MobileSelectionGestureDetector(
          onDoubleTapUp: (_) => onDoubleTapDown = true,
          child: const SizedBox.square(dimension: 50),
        ),
      );
      await tester.pumpAndSettle();

      final targetFinder = find.byType(SizedBox);
      await tester.tap(targetFinder, warnIfMissed: false);
      await tester.pump(kDoubleTapMinTime);
      await tester.tap(targetFinder, warnIfMissed: false);

      await tester.pumpAndSettle();

      expect(onDoubleTapDown, true);
    });

    testWidgets('on triple tap gesture', (tester) async {
      bool onTripleTapDown = false;

      await tester.buildAndPump(
        MobileSelectionGestureDetector(
          onTripleTapUp: (_) => onTripleTapDown = true,
          child: const SizedBox.square(dimension: 50),
        ),
      );
      await tester.pumpAndSettle();

      final targetFinder = find.byType(SizedBox);

      await tester.tap(targetFinder, warnIfMissed: false);
      await tester.pump(kDoubleTapMinTime);
      await tester.tap(targetFinder, warnIfMissed: false);
      await tester.pump(kDoubleTapMinTime);
      await tester.tap(targetFinder, warnIfMissed: false);

      await tester.pumpAndSettle();

      expect(onTripleTapDown, true);
    });
  });
}
