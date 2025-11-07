import 'package:appflowy_editor/appflowy_editor.dart';
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
    if (selection == null ||
        [SelectionUpdateReason.selectAll, SelectionUpdateReason.searchHighlight]
            .contains(editorState.selectionUpdateReason)) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectionRects = editorState.selectionRects();
      if (selectionRects.isEmpty) {
        return;
      }

      Rect targetRect;
      AxisDirection? direction;
      final dynamic dragMode =
          editorState.selectionExtraInfo?['selection_drag_mode'];

      // For desktop: if auto-scroller is already scrolling (from drag-to-select),
      // don't override it here. The desktop_selection_service handles drag scrolling.
      if (PlatformExtension.isDesktopOrWeb &&
          (editorState.autoScroller?.scrolling ?? false)) {
        return;
      }

      switch (dragMode?.toString()) {
        case 'MobileSelectionDragMode.leftSelectionHandle':
          targetRect = selectionRects.first;
          direction = AxisDirection.up;
          break;
        case 'MobileSelectionDragMode.rightSelectionHandle':
          targetRect = selectionRects.last;
          direction = AxisDirection.down;
          break;
        default:
          targetRect = selectionRects.last;

          /// sometimes moving up in a long single node may be not working
          /// so we need to special handle this case.
          final isInSingleNode = (lastSelection?.isSingle ?? false) &&
              lastSelection?.start.path == selection.start.path;
          if (selection.isForward && isInSingleNode) {
            targetRect = selectionRects.first;
          }
      }

      lastSelection = selection;

      final endTouchPoint = targetRect.centerRight;

      if (PlatformExtension.isMobile) {
        // Determine if this is a drag operation
        final bool isDragOperation = dragMode != null &&
            (dragMode.toString() ==
                    'MobileSelectionDragMode.leftSelectionHandle' ||
                dragMode.toString() ==
                    'MobileSelectionDragMode.rightSelectionHandle');

        // Use animation for drag operations, instant for others
        final scrollDuration =
            isDragOperation ? const Duration(milliseconds: 2) : Duration.zero;

        // soft keyboard
        // workaround: wait for the soft keyboard to show up
        final keyboardDelay = KeyboardHeightObserver.currentKeyboardHeight == 0
            ? const Duration(milliseconds: 250)
            : Duration.zero;

        Future.delayed(keyboardDelay, () {
          if (_forwardKey.currentContext == null) {
            return;
          }
          // Mobile needs to continuously update scroll position/direction during drag
          // Don't skip even if already scrolling, because direction may have changed
          startAutoScroll(
            endTouchPoint,
            edgeOffset: editorState.autoScrollEdgeOffset,
            direction: direction,
            duration: scrollDuration,
          );
        });
      } else {
        if (_forwardKey.currentContext == null) {
          return;
        }
        startAutoScroll(
          endTouchPoint,
          edgeOffset: editorState.autoScrollEdgeOffset,
          direction: direction,
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
