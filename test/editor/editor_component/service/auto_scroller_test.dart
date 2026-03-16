import 'package:appflowy_editor/src/editor/editor_component/service/scroll/auto_scroller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Captures the rect passed to [startAutoScrollIfNecessary] without triggering
/// real scrolling, so we can assert on the proxy rect computation.
class _CapturingAutoScroller extends AutoScroller {
  _CapturingAutoScroller(super.scrollable);

  Rect? capturedRect;

  @override
  void startAutoScrollIfNecessary(Rect dragTarget, {Duration? duration}) {
    capturedRect = dragTarget;
    // intentionally do not call super — we only want the rect
  }
}

void main() {
  group('AutoScroller.startAutoScroll', () {
    late ScrollableState scrollableState;

    setUp(() async {});

    /// Builds a minimal scrollable so we can obtain a real [ScrollableState].
    Future<void> buildScrollable(WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SingleChildScrollView(
            child: SizedBox(height: 2000),
          ),
        ),
      );
      await tester.pumpAndSettle();
      scrollableState =
          tester.state<ScrollableState>(find.byType(Scrollable).first);
    }

    // Regression test for:
    // When dragging the left selection handle upward on iOS/Android, the screen
    // was scrolling DOWN (showing content below) instead of UP (showing content
    // above). The root cause was that the proxy rect used for auto-scroll
    // detection extended 220px DOWNWARD from the selection start, so when the
    // handle was in the lower portion of the viewport the rect's bottom exceeded
    // the viewport edge and triggered a downward scroll.
    testWidgets(
      'left handle drag (AxisDirection.up) — proxy rect extends upward from offset',
      (tester) async {
        await buildScrollable(tester);

        final scroller = _CapturingAutoScroller(scrollableState);
        const offset = Offset(100, 500);
        const edgeOffset = 200.0;

        scroller.startAutoScroll(
          offset,
          edgeOffset: edgeOffset,
          direction: AxisDirection.up,
        );

        expect(scroller.capturedRect, isNotNull);

        // Rect must extend UPWARD: top = offset.dy - edgeOffset, bottom = offset.dy
        expect(
          scroller.capturedRect!.top,
          offset.dy - edgeOffset,
          reason: 'proxy rect should start edgeOffset pixels ABOVE the handle',
        );
        expect(
          scroller.capturedRect!.bottom,
          offset.dy,
          reason:
              'proxy rect bottom should be at the handle position, not below it',
        );

        // Guard: bottom must NOT be offset.dy + edgeOffset (the old buggy value
        // that caused downward scrolling when the handle was near the bottom of
        // the viewport).
        expect(
          scroller.capturedRect!.bottom,
          isNot(offset.dy + edgeOffset),
          reason:
              'old buggy value extended the rect downward, triggering wrong-direction scroll',
        );
      },
    );

    testWidgets(
      'right handle drag (AxisDirection.down) — proxy rect is centered on offset',
      (tester) async {
        await buildScrollable(tester);

        final scroller = _CapturingAutoScroller(scrollableState);
        const offset = Offset(100, 300);
        const edgeOffset = 200.0;

        scroller.startAutoScroll(
          offset,
          edgeOffset: edgeOffset,
          direction: AxisDirection.down,
        );

        expect(scroller.capturedRect, isNotNull);

        // For AxisDirection.down the generic Rect.fromCenter path is used.
        expect(
          scroller.capturedRect!.center,
          offset,
          reason:
              'right handle proxy rect should be centered on the handle offset',
        );
        expect(scroller.capturedRect!.width, edgeOffset);
        expect(scroller.capturedRect!.height, edgeOffset);
      },
    );

    testWidgets(
      'no direction — proxy rect is centered on offset',
      (tester) async {
        await buildScrollable(tester);

        final scroller = _CapturingAutoScroller(scrollableState);
        const offset = Offset(50, 200);
        const edgeOffset = 100.0;

        scroller.startAutoScroll(offset, edgeOffset: edgeOffset);

        expect(scroller.capturedRect, isNotNull);
        expect(scroller.capturedRect!.center, offset);
        expect(scroller.capturedRect!.width, edgeOffset);
        expect(scroller.capturedRect!.height, edgeOffset);
      },
    );
  });
}
