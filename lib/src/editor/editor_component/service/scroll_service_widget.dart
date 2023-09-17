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
    required this.editorScrollController,
    required this.child,
  }) : super(key: key);

  final EditorScrollController editorScrollController;

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
  late ScrollController scrollController = ScrollController();

  double offset = 0;

  @override
  void initState() {
    super.initState();
    editorState.selectionNotifier.addListener(_onSelectionChanged);
  }

  @override
  void dispose() {
    editorState.selectionNotifier.removeListener(_onSelectionChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: widget.editorScrollController,
      child: AutoScrollableWidget(
        scrollController: scrollController,
        builder: (context, autoScroller) {
          if (PlatformExtension.isDesktopOrWeb) {
            return _buildDesktopScrollService(context, autoScroller);
          } else if (PlatformExtension.isMobile) {
            return _buildMobileScrollService(context, autoScroller);
          }

          throw UnimplementedError();
        },
      ),
    );
  }

  Widget _buildDesktopScrollService(
    BuildContext context,
    AutoScroller autoScroller,
  ) {
    return DesktopScrollService(
      key: _forwardKey,
      child: widget.child,
    );
  }

  Widget _buildMobileScrollService(
    BuildContext context,
    AutoScroller autoScroller,
  ) {
    return MobileScrollService(
      key: _forwardKey,
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

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final selectionRect = editorState.selectionRects();
      if (selectionRect.isEmpty) {
        return;
      }

      final endTouchPoint = selectionRect.last.centerRight;

      if (editorState.selectionUpdateReason ==
          SelectionUpdateReason.searchNavigate) {
        return widget.editorScrollController
            .jumpTo(offset: endTouchPoint.dy - 100);
      }

      if (PlatformExtension.isMobile) {
        // soft keyboard
        // workaround: wait for the soft keyboard to show up
        return Future.delayed(const Duration(milliseconds: 300), () {
          startAutoScroll(
            endTouchPoint,
            edgeOffset: 50,
            duration: Duration.zero,
          );
        });
      } else {
        startAutoScroll(
          endTouchPoint,
          duration: Duration.zero,
        );
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
  void scrollTo(
    double dy, {
    Duration duration = const Duration(milliseconds: 150),
  }) =>
      forward.scrollTo(dy, duration: duration);

  @override
  void jumpTo(int index) => forward.jumpTo(index);

  @override
  void jumpToTop() {
    forward.jumpToTop();
  }

  @override
  void jumpToBottom() {
    forward.jumpToBottom();
  }

  @override
  void startAutoScroll(
    Offset offset, {
    double edgeOffset = 100,
    AxisDirection? direction,
    Duration? duration,
  }) {
    forward.startAutoScroll(
      offset,
      edgeOffset: edgeOffset,
      direction: direction,
      duration: duration,
    );
  }

  @override
  void stopAutoScroll() => forward.stopAutoScroll();

  @override
  void goBallistic(double velocity) => forward.goBallistic(velocity);
}
