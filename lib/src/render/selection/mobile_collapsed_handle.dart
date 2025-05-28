import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/util/platform_extension.dart';
import 'package:appflowy_editor/src/render/selection/mobile_basic_handle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MobileCollapsedHandle extends StatefulWidget {
  const MobileCollapsedHandle({
    super.key,
    required this.layerLink,
    required this.rect,
    this.handleColor = Colors.black,
    this.handleBallWidth = 6.0,
    this.handleWidth = 2.0,
    this.enableHapticFeedbackOnAndroid = true,
    this.onDragging,
  });

  final Rect rect;
  final LayerLink layerLink;
  final Color handleColor;
  final double handleWidth;
  final double handleBallWidth;
  final bool enableHapticFeedbackOnAndroid;
  final ValueChanged<bool>? onDragging;

  @override
  State<MobileCollapsedHandle> createState() => _MobileCollapsedHandleState();
}

class _MobileCollapsedHandleState extends State<MobileCollapsedHandle> {
  @override
  Widget build(BuildContext context) {
    final debugInfo = context.read<EditorState>().debugInfo;
    if (PlatformExtension.isIOS) {
      return _IOSCollapsedHandle(
        layerLink: widget.layerLink,
        rect: widget.rect,
        handleWidth: widget.handleWidth,
        debugPaintSizeEnabled: debugInfo.debugPaintSizeEnabled,
      );
    } else if (PlatformExtension.isAndroid) {
      return _AndroidCollapsedHandle(
        layerLink: widget.layerLink,
        rect: widget.rect,
        handleColor: widget.handleColor,
        handleWidth: widget.handleWidth,
        handleBallWidth: widget.handleBallWidth,
        enableHapticFeedbackOnAndroid: widget.enableHapticFeedbackOnAndroid,
        debugPaintSizeEnabled: debugInfo.debugPaintSizeEnabled,
        onDragging: widget.onDragging,
      );
    }
    throw UnsupportedError('Unsupported platform');
  }
}

class _IOSCollapsedHandle extends StatelessWidget {
  const _IOSCollapsedHandle({
    required this.layerLink,
    required this.rect,
    this.handleWidth = 2.0,
    this.debugPaintSizeEnabled = false,
  });

  final Rect rect;
  final LayerLink layerLink;
  final double handleWidth;
  final bool debugPaintSizeEnabled;

  @override
  Widget build(BuildContext context) {
    // Extend the click area to make it easier to click.
    final editorStyle = context.read<EditorState>().editorStyle;
    const defaultExtend = 10.0;
    final topExtend = editorStyle.mobileDragHandleTopExtend ?? defaultExtend;
    final leftExtend = editorStyle.mobileDragHandleLeftExtend ?? defaultExtend;
    final widthExtend =
        editorStyle.mobileDragHandleWidthExtend ?? 2 * defaultExtend;
    final heightExtend =
        editorStyle.mobileDragHandleHeightExtend ?? 2 * defaultExtend;
    final adjustedRect = Rect.fromLTWH(
      rect.left - leftExtend,
      rect.top - topExtend,
      rect.width + widthExtend,
      rect.height + heightExtend,
    );
    return Positioned.fromRect(
      rect: adjustedRect,
      child: CompositedTransformFollower(
        link: layerLink,
        offset: adjustedRect.topLeft,
        showWhenUnlinked: false,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              child: DragHandle(
                handleHeight: adjustedRect.height,
                handleType: HandleType.collapsed,
                handleColor: Colors.transparent,
                handleWidth: adjustedRect.width,
                debugPaintSizeEnabled: debugPaintSizeEnabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AndroidCollapsedHandle extends StatelessWidget {
  const _AndroidCollapsedHandle({
    required this.layerLink,
    required this.rect,
    this.handleColor = Colors.black,
    this.handleBallWidth = 6.0,
    this.handleWidth = 2.0,
    this.enableHapticFeedbackOnAndroid = true,
    this.debugPaintSizeEnabled = false,
    this.onDragging,
  });

  final Rect rect;
  final LayerLink layerLink;
  final Color handleColor;
  final double handleWidth;
  final double handleBallWidth;
  final bool enableHapticFeedbackOnAndroid;
  final bool debugPaintSizeEnabled;
  final ValueChanged<bool>? onDragging;

  @override
  Widget build(BuildContext context) {
    // Extend the click area to make it easier to click.
    final editorStyle = context.read<EditorState>().editorStyle;
    final topExtend = editorStyle.mobileDragHandleTopExtend ?? 0;
    final leftExtend =
        editorStyle.mobileDragHandleLeftExtend ?? 2 * handleBallWidth;
    final widthExtend =
        editorStyle.mobileDragHandleWidthExtend ?? 4 * handleBallWidth;
    final heightExtend =
        editorStyle.mobileDragHandleHeightExtend ?? 2 * handleBallWidth;
    final adjustedRect = Rect.fromLTWH(
      rect.left - leftExtend,
      rect.top - topExtend,
      rect.width + widthExtend,
      rect.height + heightExtend,
    );
    return Positioned.fromRect(
      rect: adjustedRect,
      child: CompositedTransformFollower(
        link: layerLink,
        offset: adjustedRect.topLeft,
        showWhenUnlinked: false,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 4.0,
              child: DragHandle(
                handleHeight: adjustedRect.height,
                handleType: HandleType.collapsed,
                handleColor: handleColor,
                handleWidth: adjustedRect.width,
                handleBallWidth: handleBallWidth,
                debugPaintSizeEnabled: debugPaintSizeEnabled,
                onDragging: onDragging,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
