import 'package:appflowy_editor/src/editor/editor_component/service/scroll/auto_scroller.dart';
import 'package:flutter/material.dart';

class AutoScrollableWidget extends StatefulWidget {
  const AutoScrollableWidget({
    super.key,
    this.shrinkWrap = false,
    required this.scrollController,
    required this.builder,
  });

  final bool shrinkWrap;
  final ScrollController scrollController;
  final Widget Function(
    BuildContext context,
    AutoScroller autoScroller,
  ) builder;

  @override
  State<AutoScrollableWidget> createState() => _AutoScrollableWidgetState();
}

class _AutoScrollableWidgetState extends State<AutoScrollableWidget> {
  late AutoScroller _autoScroller;
  late ScrollableState _scrollableState;

  @override
  Widget build(BuildContext context) {
    Widget builder(context) {
      _scrollableState = Scrollable.of(context);
      _initAutoScroller();
      return widget.builder(context, _autoScroller);
    }

    if (widget.shrinkWrap) {
      return Builder(
        builder: builder,
      );
    } else {
      return SingleChildScrollView(
        controller: widget.scrollController,
        child: Builder(
          builder: builder,
        ),
      );
    }
  }

  void _initAutoScroller() {
    _autoScroller = AutoScroller(
      _scrollableState,
      velocityScalar: 15,
      onScrollViewScrolled: () {
        _autoScroller.continueToAutoScroll();
      },
    );
  }
}
