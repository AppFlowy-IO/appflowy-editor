import 'package:appflowy_editor/src/editor/editor_component/service/scroll/auto_scrollable_widget.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/scroll/auto_scroller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test_helper.dart';

void main() {
  group('AutoScroller', () {
    testWidgets('can render', (tester) async {
      late AutoScroller scroller;

      await tester.buildAndPump(
        AutoScrollableWidget(
          scrollController: ScrollController(),
          builder: (context, autoScroller) {
            scroller = autoScroller;

            return const SizedBox(width: 600, height: 600);
          },
        ),
      );

      await tester.pumpAndSettle();

      expect(scroller.scrolling, false);
      expect(scroller.lastOffset, null);

      scroller.startAutoScroll(const Offset(10, 0));
      expect(scroller.lastOffset, const Offset(10, 0));

      scroller.stopAutoScroll();
      expect(scroller.lastOffset, null);

      scroller.startAutoScroll(
        const Offset(10, 0),
        direction: AxisDirection.up,
      );
    });
  });
}
