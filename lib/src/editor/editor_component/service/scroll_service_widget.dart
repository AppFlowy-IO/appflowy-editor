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
      final selectionRect = editorState.selectionRects();
      final endTouchPoint = selectionRect.lastOrNull?.centerRight;

      if (PlatformExtension.isMobile) {
        // soft keyboard
        // workaround: wait for the soft keyboard to show up
        final duration = KeyboardHeightObserver.currentKeyboardHeight == 0
            ? const Duration(milliseconds: 250)
            : Duration.zero;

        Future.delayed(duration, () {
          if (_forwardKey.currentContext == null) {
            return;
          }
          if (endTouchPoint == null) {
            jumpTo(selection.end.path.first);
          } else {
            startAutoScroll(
              endTouchPoint,
              edgeOffset: editorState.autoScrollEdgeOffset,
              duration: Duration.zero,
            );
          }
        });
      } else {
        if (_forwardKey.currentContext == null) {
          return;
        }
        if (endTouchPoint == null) {
          // check if the selection is valid
          final node = editorState.getNodeAtPath(selection.end.path);
          if (node == null) {
            return;
          }
          jumpTo(selection.end.path.first);
        } else {
          startAutoScroll(
            endTouchPoint,
            edgeOffset: editorState.autoScrollEdgeOffset,
            duration: Duration.zero,
          );
        }
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
