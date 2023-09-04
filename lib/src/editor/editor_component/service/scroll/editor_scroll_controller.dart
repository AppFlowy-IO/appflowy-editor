import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class EditorScrollController {
  EditorScrollController({
    ScrollController? scrollController,
  }) : scrollController = scrollController ?? ScrollController() {
    scrollOffsetListener.changes.listen((value) {
      offsetNotifier.value = offsetNotifier.value + value;
    });

    itemPositionsListener.itemPositions.addListener(() {
      final positions = itemPositionsListener.itemPositions.value;

      if (positions.isEmpty) {
        visibleRangeNotifier.value = (-1, -1);
        return;
      }

      // Determine the first visible item by finding the item with the
      // smallest trailing edge that is greater than 0.  i.e. the first
      // item whose trailing edge in visible in the viewport.
      final min = positions
          .where((ItemPosition position) => position.itemTrailingEdge > 0)
          .reduce(
            (ItemPosition min, ItemPosition position) =>
                position.itemTrailingEdge < min.itemTrailingEdge
                    ? position
                    : min,
          )
          .index;
      // Determine the last visible item by finding the item with the
      // greatest leading edge that is less than 1.  i.e. the last
      // item whose leading edge in visible in the viewport.
      final max = positions
          .where((ItemPosition position) => position.itemLeadingEdge < 1)
          .reduce(
            (ItemPosition max, ItemPosition position) =>
                position.itemLeadingEdge > max.itemLeadingEdge ? position : max,
          )
          .index;
      visibleRangeNotifier.value = (min, max);
    });
  }

  final ScrollController scrollController;

  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollOffsetController scrollOffsetController =
      ScrollOffsetController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final ScrollOffsetListener scrollOffsetListener =
      ScrollOffsetListener.create();

  final ValueNotifier<double> offsetNotifier = ValueNotifier(0);
  final ValueNotifier<(int, int)> visibleRangeNotifier =
      ValueNotifier((-1, -1));
}
