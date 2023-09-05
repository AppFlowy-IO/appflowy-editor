import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// This class controls the scroll behavior of the editor.
///
/// It must be provided in the widget tree above the [PageComponent].
///
/// You can use [offsetNotifier] to get the current scroll offset.
/// And, you can use [visibleRangeNotifier] to get the first level visible items.
///
class EditorScrollController {
  EditorScrollController() {
    // listen to the scroll offset
    _scrollOffsetSubscription = scrollOffsetListener.changes.listen((value) {
      // the value from changes is the delta offset, so we add it to the current
      // offset to get the total offset.
      offsetNotifier.value = offsetNotifier.value + value;
    });

    itemPositionsListener.itemPositions.addListener(_listenItemPositions);
  }

  final ValueNotifier<double> offsetNotifier = ValueNotifier(0);
  // provide the first level visible items, for example, if there're texts like this:
  //
  // 1. text1
  // 2. text2 ---
  //  2.1 text21|
  // ...        |
  // 5. text5   | screen
  // ...        |
  // 9. text9 ---
  // 10. text10
  //
  // So the visible range is (2-1, 9-1) = (1, 8), index start from 0.
  final ValueNotifier<(int, int)> visibleRangeNotifier =
      ValueNotifier((-1, -1));

  // these values are required by ScrollablePositionedList
  // ------------ start ----------------
  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollOffsetController scrollOffsetController =
      ScrollOffsetController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final ScrollOffsetListener scrollOffsetListener =
      ScrollOffsetListener.create();
  // ------------ end ----------------

  late final StreamSubscription<double> _scrollOffsetSubscription;

  // dispose the subscription
  void dispose() {
    _scrollOffsetSubscription.cancel();
    itemPositionsListener.itemPositions.removeListener(_listenItemPositions);
  }

  // listen to the visible item positions
  void _listenItemPositions() {
    // the value from itemPositions is the list of item positions, we need to filter
    //  the list to find the first and last visible items.
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
              position.itemTrailingEdge < min.itemTrailingEdge ? position : min,
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

    // notify the listeners
    visibleRangeNotifier.value = (min, max);
  }
}

extension ValidIndexedValueNotifier on ValueNotifier<(int, int)> {
  /// Returns true if the value is valid.
  bool get isValid => value.$1 >= 0 && value.$2 >= 0 && value.$1 <= value.$2;
}
