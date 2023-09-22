import 'dart:async';
import 'dart:math';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/flutter/scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter/material.dart';

/// This class controls the scroll behavior of the editor.
///
/// It must be provided in the widget tree above the [PageComponent].
///
/// You can use [offsetNotifier] to get the current scroll offset.
/// And, you can use [visibleRangeNotifier] to get the first level visible items.
///
/// If the shrinkWrap is true, the scrollController must not be null
///   and the editor should be wrapped in a SingleChildScrollView.
class EditorScrollController {
  EditorScrollController({
    required this.editorState,
    this.shrinkWrap = false,
    ScrollController? scrollController,
  }) {
    // if shrinkWrap is true, we will render the document with Column layout.
    // otherwise, we will render the document with ScrollablePositionedList.
    if (shrinkWrap) {
      void updateVisibleRange() {
        visibleRangeNotifier.value = (
          0,
          editorState.document.root.children.length - 1,
        );
      }

      updateVisibleRange();
      editorState.document.root.addListener(updateVisibleRange);

      shouldDisposeScrollController = scrollController == null;
      this.scrollController = scrollController ?? ScrollController();
      // listen to the scroll offset
      this.scrollController.addListener(
            () => offsetNotifier.value = this.scrollController.offset,
          );
    } else {
      // listen to the scroll offset
      _scrollOffsetSubscription = _scrollOffsetListener.changes.listen((value) {
        // the value from changes is the delta offset, so we add it to the current
        // offset to get the total offset.
        offsetNotifier.value = offsetNotifier.value + value;
      });

      _itemPositionsListener.itemPositions.addListener(_listenItemPositions);
    }
  }

  final EditorState editorState;
  final bool shrinkWrap;

  // provide the current scroll offset
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

  // these value is required by SingleChildScrollView
  // notes: don't use them if shrinkWrap is false
  // ------------ start ----------------
  late final ScrollController scrollController;
  bool shouldDisposeScrollController = false;
  // ------------ end ----------------

  // these values are required by ScrollablePositionedList
  // notes: don't use them if shrinkWrap is true
  // ------------ start ----------------
  ItemScrollController get itemScrollController {
    if (shrinkWrap) {
      throw UnsupportedError(
        'ItemScrollController is not supported '
        'when shrinkWrap is true',
      );
    }
    return _itemScrollController;
  }

  final ItemScrollController _itemScrollController = ItemScrollController();

  ScrollOffsetController get scrollOffsetController {
    if (shrinkWrap) {
      throw UnsupportedError(
        'ScrollOffsetController is not supported '
        'when shrinkWrap is true',
      );
    }
    return _scrollOffsetController;
  }

  final ScrollOffsetController _scrollOffsetController =
      ScrollOffsetController();

  ItemPositionsListener get itemPositionsListener {
    if (shrinkWrap) {
      throw UnsupportedError(
        'ItemPositionsListener is not supported '
        'when shrinkWrap is true',
      );
    }
    return _itemPositionsListener;
  }

  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  ScrollOffsetListener get scrollOffsetListener {
    if (shrinkWrap) {
      throw UnsupportedError(
        'ScrollOffsetListener is not supported '
        'when shrinkWrap is true',
      );
    }
    return _scrollOffsetListener;
  }

  final ScrollOffsetListener _scrollOffsetListener =
      ScrollOffsetListener.create();
  // ------------ end ----------------

  late final StreamSubscription<double> _scrollOffsetSubscription;

  // dispose the subscription
  void dispose() {
    if (shouldDisposeScrollController) {
      scrollController.dispose();
    }

    _scrollOffsetSubscription.cancel();
    _itemPositionsListener.itemPositions.removeListener(_listenItemPositions);
  }

  Future<void> animateTo({
    required double offset,
    required Duration duration,
    Curve curve = Curves.linear,
  }) async {
    if (shrinkWrap) {
      await scrollController.animateTo(
        offset.clamp(
          scrollController.position.minScrollExtent,
          scrollController.position.maxScrollExtent,
        ),
        duration: duration,
        curve: curve,
      );
    } else {
      await scrollOffsetController.animateTo(
        offset: max(0, offset),
        duration: duration,
        curve: curve,
      );
    }
  }

  void jumpTo({
    required double offset,
  }) async {
    if (shrinkWrap) {
      return scrollController.jumpTo(
        offset.clamp(
          scrollController.position.minScrollExtent,
          scrollController.position.maxScrollExtent,
        ),
      );
    }

    scrollOffsetController.jumpTo(offset: max(0, offset));
  }

  void jumpToTop() {
    if (shrinkWrap) {
      scrollController.jumpTo(0);
    } else {
      itemScrollController.jumpTo(index: 0);
    }
  }

  void jumpToBottom() {
    if (shrinkWrap) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    } else {
      itemScrollController.jumpTo(
        index: editorState.document.root.children.length - 1,
      );
    }
  }

  // listen to the visible item positions
  void _listenItemPositions() {
    // the value from itemPositions is the list of item positions, we need to filter
    //  the list to find the first and last visible items.
    final positions = _itemPositionsListener.itemPositions.value;

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
