import 'package:appflowy_editor/src/editor/editor_component/service/scroll/auto_scrollable_widget.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/scroll/auto_scroller.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/scroll/mobile_scroll_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test_helper.dart';

void main() {
  group('MobileScrollService', () {
    testWidgets('can render', (tester) async {
      await tester.buildAndPump(
        MobileScrollService(
          scrollController: ScrollController(),
          autoScroller: AutoScroller(ScrollableState()),
          child: const SizedBox.shrink(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MobileScrollService), findsOneWidget);
    });

    testWidgets('state', (tester) async {
      final scrollController = ScrollController(debugLabel: 'test');
      await tester.buildAndPump(
        AutoScrollableWidget(
          scrollController: scrollController,
          builder: (context, scroller) => MobileScrollService(
            scrollController: scrollController,
            autoScroller: AutoScroller(ScrollableState()),
            child: const SizedBox.shrink(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final state = tester.state(find.byType(MobileScrollService))
          as MobileScrollServiceState;

      expect(state.dy, 0);

      expect(state.onePageHeight, 600.0);

      expect(state.maxScrollExtent, 0);

      expect(state.minScrollExtent, 0);

      expect(state.page, 0);

      expect(state.scrollController.debugLabel, 'test');
    });

    testWidgets('scroll', (tester) async {
      final scrollController = ScrollController(debugLabel: 'test');
      await tester.buildAndPump(
        AutoScrollableWidget(
          scrollController: scrollController,
          builder: (context, scroller) => MobileScrollService(
            scrollController: scrollController,
            autoScroller: AutoScroller(ScrollableState()),
            child: const SizedBox.shrink(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final state = tester.state(find.byType(MobileScrollService))
          as MobileScrollServiceState;

      expect(state.dy, 0);

      state.scrollTo(10);
      await tester.pumpAndSettle();
    });

    testWidgets('enable/disable', (tester) async {
      final scrollController = ScrollController(debugLabel: 'test');
      await tester.buildAndPump(
        AutoScrollableWidget(
          scrollController: scrollController,
          builder: (context, scroller) => MobileScrollService(
            scrollController: scrollController,
            autoScroller: AutoScroller(ScrollableState()),
            child: const SizedBox.shrink(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final state = tester.state(find.byType(MobileScrollService))
          as MobileScrollServiceState;

      state.enable();
      state.disable();
    });
  });
}
