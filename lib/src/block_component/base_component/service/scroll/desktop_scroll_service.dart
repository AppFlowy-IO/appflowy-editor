import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/block_component/base_component/service/scroll/auto_scroller.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class DesktopScrollService extends StatefulWidget {
  const DesktopScrollService({
    Key? key,
    required this.scrollController,
    required this.autoScroller,
    required this.child,
  }) : super(key: key);

  final ScrollController scrollController;
  final AutoScroller autoScroller;

  final Widget child;

  @override
  State<DesktopScrollService> createState() => _DesktopScrollServiceState();
}

class _DesktopScrollServiceState extends State<DesktopScrollService>
    implements AppFlowyScrollService {
  bool _scrollEnabled = true;

  @override
  double get dy => widget.scrollController.position.pixels;

  @override
  double? get onePageHeight {
    final renderBox = context.findRenderObject()?.unwrapOrNull<RenderBox>();
    return renderBox?.size.height;
  }

  @override
  double get maxScrollExtent =>
      widget.scrollController.position.maxScrollExtent;

  @override
  double get minScrollExtent =>
      widget.scrollController.position.minScrollExtent;

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
      child: widget.child,
    );
  }

  @override
  void scrollTo(double dy) {
    widget.scrollController.position.jumpTo(
      dy.clamp(
        widget.scrollController.position.minScrollExtent,
        widget.scrollController.position.maxScrollExtent,
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
      final dy =
          (widget.scrollController.position.pixels + event.scrollDelta.dy);
      scrollTo(dy);
    }
  }

  void _onPointerPanZoomUpdate(PointerPanZoomUpdateEvent event) {
    if (_scrollEnabled) {
      final dy = (widget.scrollController.position.pixels - event.panDelta.dy);
      scrollTo(dy);
    }
  }

  @override
  void startAutoScroll(Offset offset) =>
      widget.autoScroller.startAutoScroll(offset);

  @override
  void stopAutoScroll() {
    // TODO: implement stopAutoScroll
  }
}
