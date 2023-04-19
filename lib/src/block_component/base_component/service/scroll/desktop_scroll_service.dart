import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AppFlowyScroll extends StatefulWidget {
  const AppFlowyScroll({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  State<AppFlowyScroll> createState() => _AppFlowyScrollState();
}

class _AppFlowyScrollState extends State<AppFlowyScroll>
    implements AppFlowyScrollService {
  final _scrollController = ScrollController();
  final _scrollViewKey = GlobalKey();

  bool _scrollEnabled = true;

  @override
  double get dy => _scrollController.position.pixels;

  @override
  double? get onePageHeight {
    final renderBox = context.findRenderObject()?.unwrapOrNull<RenderBox>();
    return renderBox?.size.height;
  }

  @override
  double get maxScrollExtent => _scrollController.position.maxScrollExtent;

  @override
  double get minScrollExtent => _scrollController.position.minScrollExtent;

  @override
  int? get page {
    if (onePageHeight != null) {
      final scrollExtent = maxScrollExtent - minScrollExtent;
      return (scrollExtent / onePageHeight!).ceil();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: _onPointerSignal,
      onPointerPanZoomUpdate: _onPointerPanZoomUpdate,
      child: CustomScrollView(
        key: _scrollViewKey,
        physics: const NeverScrollableScrollPhysics(),
        controller: _scrollController,
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: widget.child,
          )
        ],
      ),
    );
  }

  @override
  void scrollTo(double dy) {
    _scrollController.position.jumpTo(
      dy.clamp(
        _scrollController.position.minScrollExtent,
        _scrollController.position.maxScrollExtent,
      ),
    );
  }

  @override
  void disable() {
    _scrollEnabled = false;
    Log.scroll.debug('disable scroll service');
  }

  @override
  void enable() {
    _scrollEnabled = true;
    Log.scroll.debug('enable scroll service');
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent && _scrollEnabled) {
      final dy = (_scrollController.position.pixels + event.scrollDelta.dy);
      scrollTo(dy);
    }
  }

  void _onPointerPanZoomUpdate(PointerPanZoomUpdateEvent event) {
    if (_scrollEnabled) {
      final dy = (_scrollController.position.pixels - event.panDelta.dy);
      scrollTo(dy);
    }
  }
}
