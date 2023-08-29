import 'package:appflowy_editor/src/service/selection_gesture_detector/mobile_selection_gesture_detector.dart';
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
      bool onTap = false;

      await tester.buildAndPump(
        MobileSelectionGestureDetector(
          onTap: () => onTap = true,
          child: const SizedBox.square(dimension: 50),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SizedBox), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(onTap, true);
    });

    testWidgets('on double tap gesture', (tester) async {
      bool onDoubleTapDown = false;

      await tester.buildAndPump(
        MobileSelectionGestureDetector(
          onDoubleTapDown: (_) => onDoubleTapDown = true,
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

    testWidgets('on double tap gesture', (tester) async {
      bool onDoubleTap = false;

      await tester.buildAndPump(
        MobileSelectionGestureDetector(
          onDoubleTap: () => onDoubleTap = true,
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

      expect(onDoubleTap, true);
    });
  });
}
