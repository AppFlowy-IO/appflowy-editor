import 'package:flutter/material.dart';

class DesktopScrollService extends StatefulWidget {
  const DesktopScrollService({
    Key? key,
    this.scrollController,
    required this.child,
  }) : super(key: key);

  final ScrollController? scrollController;
  final Widget child;

  @override
  State<DesktopScrollService> createState() => _DesktopScrollServiceState();
}

class _DesktopScrollServiceState extends State<DesktopScrollService> {
  late EdgeDraggingAutoScroller _autoScroller;
  late ScrollController _scrollController;
  late ScrollableState _scrollableState;

  @override
  void initState() {
    super.initState();

    _scrollController = widget.scrollController ?? ScrollController();

    // TODO: Any good idea to get the scrollable area?
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _initAutoScroller();
    });
  }

  @override
  void didUpdateWidget(covariant DesktopScrollService oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.scrollController != oldWidget.scrollController) {
      if (oldWidget.scrollController == null) {
        // create by self
        _scrollController.dispose();
      }
      _scrollController = widget.scrollController ?? ScrollController();
      _autoScroller.stopAutoScroll();
      _initAutoScroller();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      controller: _scrollController,
      child: Builder(
        builder: (context) {
          _scrollableState = Scrollable.of(context);
          return widget.child;
        },
      ),
    );
  }

  void _initAutoScroller() {
    _autoScroller = EdgeDraggingAutoScroller(
      _scrollableState,
      velocityScalar: 30,
      onScrollViewScrolled: () {},
    );
  }
}
