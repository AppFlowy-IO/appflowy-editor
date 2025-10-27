import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const Duration _kDesktopAutoScrollTickDuration = Duration(milliseconds: 80);

class DesktopScrollService extends StatefulWidget {
  const DesktopScrollService({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<DesktopScrollService> createState() => _DesktopScrollServiceState();
}

class _DesktopScrollServiceState extends State<DesktopScrollService>
    implements AppFlowyScrollService {
  late final editorState = context.read<EditorState>();
  late final autoScroller = editorState.autoScroller;
  late final editorScrollController = context.read<EditorScrollController>();

  @override
  double get dy => context.read<EditorScrollController>().offsetNotifier.value;

  @override
  double? get onePageHeight {
    final renderBox = context.findRenderObject() as RenderBox?;
    return renderBox?.size.height;
  }

  @override
  double get maxScrollExtent =>
      editorState.scrollableState!.position.maxScrollExtent;

  @override
  double get minScrollExtent =>
      editorState.scrollableState!.position.minScrollExtent;

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
    Duration duration = const Duration(
      milliseconds: 150,
    ),
  }) {
    dy = dy.clamp(
      minScrollExtent,
      maxScrollExtent,
    );
    editorScrollController.animateTo(
      offset: dy,
      duration: duration,
    );
  }

  @override
  void jumpToTop() {
    editorScrollController.jumpToTop();
  }

  @override
  void jumpToBottom() {
    editorScrollController.jumpToBottom();
  }

  @override
  void jumpTo(int index) {
    editorScrollController.jumpTo(offset: index.toDouble());
  }

  @override
  void disable() {
    AppFlowyEditorLog.scroll.debug('disable scroll service');
  }

  @override
  void enable() {
    AppFlowyEditorLog.scroll.debug('enable scroll service');
  }

  @override
  void startAutoScroll(
    Offset offset, {
    double edgeOffset = 200,
    AxisDirection? direction,
    Duration? duration,
  }) {
    if (editorState.disableAutoScroll) {
      return;
    }

    autoScroller?.startAutoScroll(
      offset,
      edgeOffset: edgeOffset,
      direction: direction,
      duration: duration ?? _kDesktopAutoScrollTickDuration,
    );
  }

  @override
  void stopAutoScroll() {
    if (editorState.disableAutoScroll) {
      return;
    }

    autoScroller?.stopAutoScroll();
  }

  @override
  void goBallistic(double velocity) {
    throw UnimplementedError();
  }

  @override
  ScrollController get scrollController => throw UnimplementedError();
}
