import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/selection/mobile_selection_service.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/scroll/desktop_scroll_service.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/scroll/mobile_scroll_service.dart';
import 'package:appflowy_editor/src/editor/toolbar/mobile/utils/keyboard_height_observer.dart';
import 'package:appflowy_editor/src/editor/util/platform_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScrollServiceWidget extends StatefulWidget {
  const ScrollServiceWidget({
    super.key,
    required this.editorScrollController,
    required this.child,
  });

  final EditorScrollController editorScrollController;

  final Widget child;

  @override
  State<ScrollServiceWidget> createState() => _ScrollServiceWidgetState();
}

class _ScrollServiceWidgetState extends State<ScrollServiceWidget>
    implements AppFlowyScrollService {
  final _forwardKey =
      GlobalKey(debugLabel: 'forward_to_platform_scroll_service');
  late AppFlowyScrollService forward =
      _forwardKey.currentState as AppFlowyScrollService;

  late EditorState editorState = context.read<EditorState>();

  @override
  late ScrollController scrollController = ScrollController();

  Selection? lastSelection;

  @override
  void initState() {
    super.initState();
    editorState.selectionNotifier.addListener(_onSelectionChanged);
  }

  @override
  void dispose() {
    scrollController.dispose();
    editorState.selectionNotifier.removeListener(_onSelectionChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: widget.editorScrollController,
      child: Builder(
        builder: (context) {
          if (PlatformExtension.isDesktopOrWeb) {
            return _buildDesktopScrollService(context);
          } else if (PlatformExtension.isMobile) {
            return _buildMobileScrollService(context);
          }
          throw UnimplementedError();
        },
      ),
    );
  }

  Widget _buildDesktopScrollService(
    BuildContext context,
  ) {
    return DesktopScrollService(
      key: _forwardKey,
      child: widget.child,
    );
  }

  Widget _buildMobileScrollService(
    BuildContext context,
  ) {
    return MobileScrollService(
      key: _forwardKey,
      child: widget.child,
    );
  }

  void _onSelectionChanged() {
    // should auto scroll after the cursor or selection updated.
    final selection = editorState.selection;
    final reason = editorState.selectionUpdateReason;
    // Remote transactions rebase the local selection so it stays valid, but
    // they must not make this client follow that selection in the viewport.
    if (selection == null ||
        reason == SelectionUpdateReason.remote ||
        reason == SelectionUpdateReason.selectAll) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectionRects = editorState.selectionRects();
      if (selectionRects.isEmpty) {
        return;
      }

      final bool isDraggingSelection =
          isMobileSelectionDragging(editorState.selectionExtraInfo);

      // For desktop: if auto-scroller is already scrolling (from drag-to-select),
      // don't override it here. The desktop_selection_service handles drag scrolling.
      if (PlatformExtension.isDesktopOrWeb &&
          (editorState.autoScroller?.scrolling ?? false)) {
        return;
      }

      final previousSelection = lastSelection;
      lastSelection = selection;

      // On mobile the selection service drives the auto scroll while a
      // selection handle is being dragged, because only the service knows
      // where the pointer is.
      //
      // Overriding it here with the selection rect would break the edge
      // detection: the selection rect is glued to the content, so it never
      // reaches the edge of the viewport and the document would stop scrolling
      // as soon as the content moved.
      if (PlatformExtension.isMobile && isDraggingSelection) {
        return;
      }

      var targetRect = selectionRects.last;

      /// sometimes moving up in a long single node may be not working
      /// so we need to special handle this case.
      final isLastSelectionSingle = previousSelection?.isSingle ?? false;
      final isLastSelectionPathEqual =
          previousSelection?.start.path.equals(selection.start.path) ?? false;
      final isInSingleNode = isLastSelectionSingle && isLastSelectionPathEqual;
      if (selection.isForward && isInSingleNode) {
        targetRect = selectionRects.first;
      }

      final endTouchPoint = targetRect.centerRight;

      if (PlatformExtension.isMobile) {
        // soft keyboard
        // workaround: wait for the soft keyboard to show up
        final keyboardDelay = KeyboardHeightObserver.currentKeyboardHeight == 0
            ? const Duration(milliseconds: 250)
            : Duration.zero;

        Future.delayed(keyboardDelay, () {
          if (_forwardKey.currentContext == null) {
            return;
          }
          // A drag may have started while we were waiting for the soft
          // keyboard. The selection service drives the auto scroll while a
          // handle is dragged, so we must not override it here.
          if (isMobileSelectionDragging(editorState.selectionExtraInfo)) {
            return;
          }
          // The selection is scrolled into a comfortable reading position.
          // The proxy rect is a square centered on the selection, so the
          // document scrolls away from the edge of the viewport that the
          // selection is close to.
          startAutoScroll(
            endTouchPoint,
            edgeOffset: editorState.autoScrollEdgeOffset,
            duration: Duration.zero,
          );
        });
      } else {
        if (_forwardKey.currentContext == null) {
          return;
        }
        startAutoScroll(
          endTouchPoint,
          edgeOffset: editorState.autoScrollEdgeOffset,
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
