import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/block_component/base_component/service/scroll/auto_scrollable_widget.dart';
import 'package:appflowy_editor/src/block_component/base_component/service/scroll/auto_scroller.dart';
import 'package:appflowy_editor/src/block_component/base_component/service/scroll/desktop_scroll_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ScrollServiceWidget extends StatefulWidget {
  const ScrollServiceWidget({
    Key? key,
    this.scrollController,
    required this.child,
  }) : super(key: key);

  final ScrollController? scrollController;
  final Widget child;

  @override
  State<ScrollServiceWidget> createState() => _ScrollServiceWidgetState();
}

class _ScrollServiceWidgetState extends State<ScrollServiceWidget>
    implements AppFlowyScrollService {
  final _forwardKey =
      GlobalKey(debugLabel: 'forward_to_platform_scroll_service');
  AppFlowyScrollService get forward =>
      _forwardKey.currentState as AppFlowyScrollService;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = widget.scrollController ?? ScrollController();
  }

  @override
  void didUpdateWidget(covariant ScrollServiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.scrollController != oldWidget.scrollController) {
      if (oldWidget.scrollController == null) {
        // create by self
        _scrollController.dispose();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AutoScrollableWidget(
      scrollController: _scrollController,
      builder: ((context, autoScroller) {
        if (kIsWeb ||
            Platform.isLinux ||
            Platform.isMacOS ||
            Platform.isWindows) {
          return _buildDesktopScrollService(context, autoScroller);
        } else if (Platform.isIOS || Platform.isAndroid) {
          return _buildMobileScrollService(context, autoScroller);
        }
        throw UnimplementedError();
      }),
    );
  }

  Widget _buildDesktopScrollService(
    BuildContext context,
    AutoScroller autoScroller,
  ) {
    return DesktopScrollService(
      key: _forwardKey,
      scrollController: _scrollController,
      autoScroller: autoScroller,
      child: widget.child,
    );
  }

  Widget _buildMobileScrollService(
    BuildContext context,
    AutoScroller autoScroller,
  ) {
    return DesktopScrollService(
      key: _forwardKey,
      scrollController: _scrollController,
      autoScroller: autoScroller,
      child: widget.child,
    );
  }

  @override
  void disable() => forward.disable();

  @override
  double get dy => forward.dy;

  @override
  void enable() => forward.enable();

  @override
  double get maxScrollExtent => forward.maxScrollExtent;

  @override
  double get minScrollExtent => forward.minScrollExtent;

  @override
  double? get onePageHeight => forward.onePageHeight;

  @override
  int? get page => forward.page;

  @override
  void scrollTo(double dy) => forward.scrollTo(dy);

  @override
  void startAutoScrollIfNecessary(Rect dragTarget) =>
      forward.startAutoScrollIfNecessary(dragTarget);

  @override
  void stopAutoScroll() => forward.stopAutoScroll();
}
