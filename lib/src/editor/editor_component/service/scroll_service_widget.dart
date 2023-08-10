import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/scroll/auto_scrollable_widget.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/scroll/auto_scroller.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/scroll/desktop_scroll_service.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/scroll/mobile_scroll_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScrollServiceWidget extends StatefulWidget {
  const ScrollServiceWidget({
    Key? key,
    this.shrinkWrap = false,
    this.scrollController,
    required this.child,
  }) : super(key: key);

  final ScrollController? scrollController;
  final bool shrinkWrap;
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

  late EditorState editorState = context.read<EditorState>();

  @override
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    scrollController = widget.scrollController ?? ScrollController();
    editorState.selectionNotifier.addListener(_onSelectionChanged);
  }

  @override
  void dispose() {
    editorState.selectionNotifier.removeListener(_onSelectionChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ScrollServiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.scrollController != oldWidget.scrollController) {
      if (oldWidget.scrollController == null) {
        // create by self
        scrollController.dispose();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AutoScrollableWidget(
      shrinkWrap: widget.shrinkWrap,
      scrollController: scrollController,
      builder: (context, autoScroller) {
        if (PlatformExtension.isDesktopOrWeb) {
          return _buildDesktopScrollService(context, autoScroller);
        } else if (PlatformExtension.isMobile) {
          return _buildMobileScrollService(context, autoScroller);
        }

        throw UnimplementedError();
      },
    );
  }

  Widget _buildDesktopScrollService(
    BuildContext context,
    AutoScroller autoScroller,
  ) {
    return DesktopScrollService(
      key: _forwardKey,
      scrollController: scrollController,
      autoScroller: autoScroller,
      child: widget.child,
    );
  }

  Widget _buildMobileScrollService(
    BuildContext context,
    AutoScroller autoScroller,
  ) {
    return MobileScrollService(
      key: _forwardKey,
      scrollController: scrollController,
      autoScroller: autoScroller,
      child: widget.child,
    );
  }

  void _onSelectionChanged() {
    // should auto scroll after the cursor or selection updated.
    final selection = editorState.selection;
    if (selection == null ||
        [SelectionUpdateReason.selectAll, SelectionUpdateReason.searchHighlight]
            .contains(editorState.selectionUpdateReason)) {
      return;
    }

    final updateReason = editorState.selectionUpdateReason;
    final selectionType = editorState.selectionType;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final selectionRect = editorState.selectionRects();
      if (selectionRect.isEmpty) {
        return;
      }

      final endTouchPoint = selectionRect.last.centerRight;

      if (editorState.selectionUpdateReason ==
          SelectionUpdateReason.searchNavigate) {
        scrollController.jumpTo(endTouchPoint.dy - 100);
        return;
      }

      if (selection.isCollapsed) {
        if (PlatformExtension.isMobile) {
          // soft keyboard
          // workaround: wait for the soft keyboard to show up
          Future.delayed(const Duration(milliseconds: 300), () {
            startAutoScroll(endTouchPoint, edgeOffset: 50);
          });
        } else {
          if (selectionType == SelectionType.block ||
              updateReason == SelectionUpdateReason.transaction) {
            final box = editorState.renderBox;
            final editorOffset = box?.localToGlobal(Offset.zero);
            final editorHeight = box?.size.height;
            double offset = 100;
            if (editorOffset != null && editorHeight != null) {
              // try to center the highlight area
              offset = editorOffset.dy + editorHeight / 2.0;
            }
            startAutoScroll(
              endTouchPoint,
              edgeOffset: offset,
              duration: Duration.zero,
            );
          } else {
            startAutoScroll(endTouchPoint, edgeOffset: 100);
          }
        }
      } else {
        startAutoScroll(endTouchPoint);
      }
    });
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
  void scrollTo(double dy, {Duration? duration}) =>
      forward.scrollTo(dy, duration: duration);

  @override
  void startAutoScroll(
    Offset offset, {
    double edgeOffset = 100,
    AxisDirection? direction,
    Duration? duration,
  }) =>
      forward.startAutoScroll(
        offset,
        edgeOffset: edgeOffset,
        direction: direction,
        duration: duration,
      );

  @override
  void stopAutoScroll() => forward.stopAutoScroll();

  @override
  void goBallistic(double velocity) => forward.goBallistic(velocity);
}
