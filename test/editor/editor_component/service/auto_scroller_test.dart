import 'package:appflowy_editor/appflowy_editor.dart';
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

  /// Exposes the protected viewport resolution, so that the tests are able to
  /// assert on the rect that is used for the edge detection.
  Rect resolveViewport(Rect globalRect) => resolveViewportRect(globalRect);
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
          direction: AxisDirection.down,
        );

        expect(scroller.capturedRect, isNotNull);

        // For AxisDirection.down the rect starts at offset and extends downward.
        expect(
          scroller.capturedRect!.top,
          offset.dy,
          reason: 'proxy rect should start at the handle position',
        );
        expect(
          scroller.capturedRect!.bottom,
          offset.dy + edgeOffset,
          reason: 'proxy rect should extend edgeOffset pixels BELOW the handle',
        );
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

    // The auto scroll while dragging a selection handle uses a square that is
    // centered on the pointer. The direction of the scroll is derived from the
    // position of the pointer relative to the viewport, which means that both
    // handles are able to scroll the document up and down.
    testWidgets(
      'drag proxy rect — crosses the viewport edge only close to the edge',
      (tester) async {
        await buildScrollable(tester);

        final scroller = _CapturingAutoScroller(scrollableState);
        const edgeOffset = appFlowyEditorAutoScrollDragEdgeOffset;

        final renderBox =
            scrollableState.context.findRenderObject()! as RenderBox;
        final viewport = renderBox.localToGlobal(Offset.zero) & renderBox.size;

        // the pointer is in the middle of the viewport
        scroller.startAutoScroll(
          Offset(50, viewport.center.dy),
          edgeOffset: edgeOffset,
        );
        expect(
          scroller.capturedRect!.top,
          greaterThan(viewport.top),
          reason: 'the proxy rect must not reach the top of the viewport',
        );
        expect(
          scroller.capturedRect!.bottom,
          lessThan(viewport.bottom),
          reason: 'the proxy rect must not reach the bottom of the viewport',
        );

        // the pointer is close to the bottom of the viewport
        scroller.startAutoScroll(
          Offset(50, viewport.bottom - 20),
          edgeOffset: edgeOffset,
        );
        expect(
          scroller.capturedRect!.bottom,
          greaterThan(viewport.bottom),
          reason: 'the proxy rect must reach the bottom of the viewport',
        );

        // the pointer is close to the top of the viewport
        scroller.startAutoScroll(
          Offset(50, viewport.top + 20),
          edgeOffset: edgeOffset,
        );
        expect(
          scroller.capturedRect!.top,
          lessThan(viewport.top),
          reason: 'the proxy rect must reach the top of the viewport',
        );
      },
    );
  });

  group('AutoScroller.resolveViewportRect', () {
    /// The viewport of the editor is not always the visible area of the
    /// screen. A host application may render the editor behind the system
    /// status bar or behind the on screen keyboard, and the auto scroll has to
    /// be triggered relative to the visible area, otherwise the document only
    /// starts to scroll when the selection handle is already invisible.
    testWidgets(
      'the viewport is clamped to the visible area of the screen',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        tester.view.padding = const FakeViewPadding(top: 100, bottom: 50);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          const MaterialApp(
            home: SingleChildScrollView(
              child: SizedBox(height: 2000),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final scrollableState =
            tester.state<ScrollableState>(find.byType(Scrollable).first);
        final scroller = _CapturingAutoScroller(scrollableState);

        final renderBox =
            scrollableState.context.findRenderObject()! as RenderBox;
        final viewport = renderBox.localToGlobal(Offset.zero) & renderBox.size;

        // the editor fills the whole screen, like an immersive layout does
        expect(viewport.top, 0);

        final resolved = scroller.resolveViewport(viewport);

        expect(
          resolved.top,
          100,
          reason: 'the status bar is not part of the visible area',
        );
        expect(
          resolved.bottom,
          1200,
          reason: 'the bottom of the screen is visible',
        );
      },
    );

    testWidgets(
      'the viewport is not moved when it is already inside the visible area',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        tester.view.padding = const FakeViewPadding(top: 100, bottom: 50);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          const MaterialApp(
            home: Padding(
              padding: EdgeInsets.only(top: 200, bottom: 100),
              child: SingleChildScrollView(
                child: SizedBox(height: 2000),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final scrollableState =
            tester.state<ScrollableState>(find.byType(Scrollable).first);
        final scroller = _CapturingAutoScroller(scrollableState);

        final renderBox =
            scrollableState.context.findRenderObject()! as RenderBox;
        final viewport = renderBox.localToGlobal(Offset.zero) & renderBox.size;

        final resolved = scroller.resolveViewport(viewport);

        expect(
          resolved.top,
          viewport.top,
          reason: 'the viewport must not be moved down',
        );
        expect(
          resolved.bottom,
          viewport.bottom,
          reason: 'the viewport must not be moved up',
        );
      },
    );

    testWidgets(
      'the on screen keyboard is not part of the visible area',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        tester.view.viewInsets = const FakeViewPadding(bottom: 400);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          const MaterialApp(
            home: SingleChildScrollView(
              child: SizedBox(height: 2000),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final scrollableState =
            tester.state<ScrollableState>(find.byType(Scrollable).first);
        final scroller = _CapturingAutoScroller(scrollableState);

        final renderBox =
            scrollableState.context.findRenderObject()! as RenderBox;
        final viewport = renderBox.localToGlobal(Offset.zero) & renderBox.size;

        final resolved = scroller.resolveViewport(viewport);

        expect(
          resolved.bottom,
          800,
          reason: 'the keyboard is not part of the visible area',
        );
      },
    );
  });

  group('AutoScroller drag margin', () {
    testWidgets(
      'the top inset of the host application is not part of the visible area',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        tester.view.padding = const FakeViewPadding(top: 100);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          const MaterialApp(
            home: SingleChildScrollView(
              child: SizedBox(height: 2000),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final scrollableState =
            tester.state<ScrollableState>(find.byType(Scrollable).first);
        final scroller = _CapturingAutoScroller(scrollableState)..topInset = 44;

        final renderBox =
            scrollableState.context.findRenderObject()! as RenderBox;
        final viewport = renderBox.localToGlobal(Offset.zero) & renderBox.size;

        final resolved = scroller.resolveViewport(viewport);

        expect(
          resolved.top,
          144,
          reason: 'the app bar of the host application covers the top of '
              'the editor',
        );
      },
    );

    testWidgets(
      'the proxy rect leaves a margin of 40 pixels at the edge',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: SingleChildScrollView(
              child: SizedBox(height: 2000),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final scrollableState =
            tester.state<ScrollableState>(find.byType(Scrollable).first);
        final scroller = _CapturingAutoScroller(scrollableState);

        const offset = Offset(100, 500);
        scroller.startAutoScroll(
          offset,
          edgeOffset: appFlowyEditorAutoScrollDragEdgeOffset,
        );

        // the proxy rect is centered on the pointer, so the document starts
        // to scroll when the pointer is 40 pixels away from the edge of the
        // visible area.
        expect(scroller.capturedRect!.top, offset.dy - 40);
        expect(scroller.capturedRect!.bottom, offset.dy + 40);
      },
    );
  });
}
