import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/scroll/auto_scroller.dart';
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
  @override
  double get dy => widget.scrollController.position.pixels;
  @override
  bool get implicit => widget.scrollController.position.allowImplicitScrolling;
  @override
  double get offset => widget.scrollController.offset;
  @override
  double? get onePageHeight {
    final renderBox = context.findRenderObject() as RenderBox?;
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
    return widget.child;
  }

  @override
  void scrollTo(
    double dy, {
    Duration? duration,
  }) {
    dy = dy.clamp(
      widget.scrollController.position.minScrollExtent,
      widget.scrollController.position.maxScrollExtent,
    );
    if (duration != null) {
      widget.scrollController.position.animateTo(
        dy,
        duration: duration,
        curve: Curves.bounceInOut,
      );
    } else {
      widget.scrollController.position.jumpTo(dy);
    }
  }

  @override
  void disable() {
    Log.scroll.debug('disable scroll service');
  }

  @override
  void enable() {
    Log.scroll.debug('enable scroll service');
  }

  @override
  void startAutoScroll(
    Offset offset, {
    double edgeOffset = 200,
    AxisDirection? direction,
  }) {
    widget.autoScroller.startAutoScroll(
      offset,
      edgeOffset: edgeOffset,
      direction: direction,
    );
  }

  @override
  void stopAutoScroll() {
    widget.autoScroller.stopAutoScroll();
  }

  @override
  void goBallistic(double velocity) {
    final position = widget.scrollController.position;
    if (position is ScrollPositionWithSingleContext) {
      position.goBallistic(velocity);
    }
  }

  @override
  ScrollController get scrollController => widget.scrollController;

  @override
  void scrollOnUpdate(
    EditorState editorState, {
    Rect? cursorRect,
    BuildContext? context,
    List<Node>? currentSelectedNodes,
    Selection? currentSelection,
  }) {
    widget.autoScroller.scrollOnUpdate(
      editorState,
      cursorRect: cursorRect,
      context: context,
      currentSelectedNodes: currentSelectedNodes,
      currentSelection: currentSelection,
    );
    // TODO: implement scrollOnUpdate
  }
}
