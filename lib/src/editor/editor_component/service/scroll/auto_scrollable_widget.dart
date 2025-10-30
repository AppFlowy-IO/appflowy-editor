import 'package:appflowy_editor/src/editor/editor_component/service/scroll/auto_scroller.dart';
import 'package:appflowy_editor/src/editor_state.dart';
import 'package:appflowy_editor/src/editor/util/platform_extension.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const _selectionDragModeKey = 'selection_drag_mode';

class AutoScrollableWidget extends StatefulWidget {
  const AutoScrollableWidget({
    super.key,
    this.shrinkWrap = false,
    required this.scrollController,
    required this.builder,
  });

  final bool shrinkWrap;
  final ScrollController scrollController;
  final Widget Function(
    BuildContext context,
    AutoScroller autoScroller,
  ) builder;

  @override
  State<AutoScrollableWidget> createState() => _AutoScrollableWidgetState();
}

class _AutoScrollableWidgetState extends State<AutoScrollableWidget> {
  late AutoScroller _autoScroller;
  late ScrollableState _scrollableState;

  @override
  void dispose() {
    // ignore: invalid_use_of_protected_member
    _scrollableState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget builder(context) {
      return widget.builder(context, _autoScroller);
    }

    _scrollableState = ScrollableState();
    _initAutoScroller();

    if (widget.shrinkWrap) {
      return widget.builder(context, _autoScroller);
    } else {
      return Builder(
        builder: builder,
      );
    }
  }

  void _initAutoScroller() {
    final bool isDesktopOrWeb = PlatformExtension.isDesktopOrWeb;
    _autoScroller = AutoScroller(
      _scrollableState,
      velocityScalar: isDesktopOrWeb ? 0.125 : 0.02,
      minimumAutoScrollDelta: isDesktopOrWeb ? 0.07 : 0.004,
      maxAutoScrollDelta: isDesktopOrWeb ? 2.75 : 0.053,
      onScrollViewScrolled: () {
        if (!isDesktopOrWeb) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              final editorState = context.read<EditorState?>();
              final dynamic dragMode =
                  editorState?.selectionExtraInfo?[_selectionDragModeKey];
              final bool isDraggingSelection = dragMode != null &&
                  dragMode.toString() != 'MobileSelectionDragMode.none';
              if (!isDraggingSelection) {
                return;
              }
              _autoScroller.continueToAutoScroll();
            }
          });
        }
      },
    );
  }
}
