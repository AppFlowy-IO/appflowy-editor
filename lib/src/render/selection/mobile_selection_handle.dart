import 'dart:io';
import 'dart:math';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/selection/mobile_selection_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

GlobalKey _mobileLeftHandleKey = GlobalKey();
GlobalKey _mobileRightHandleKey = GlobalKey();
GlobalKey _mobileCollapsedHandleKey = GlobalKey();

enum HandleType {
  none,
  left,
  right,
  collapsed;

  GlobalKey get key {
    switch (this) {
      case HandleType.none:
        throw UnsupportedError('Unsupported handle type');
      case HandleType.left:
        return _mobileLeftHandleKey;
      case HandleType.right:
        return _mobileRightHandleKey;
      case HandleType.collapsed:
        return _mobileCollapsedHandleKey;
    }
  }

  MobileSelectionDragMode get dragMode {
    switch (this) {
      case HandleType.none:
        throw UnsupportedError('Unsupported handle type');
      case HandleType.left:
        return MobileSelectionDragMode.leftSelectionHandler;
      case HandleType.right:
        return MobileSelectionDragMode.rightSelectionHandler;
      case HandleType.collapsed:
        return MobileSelectionDragMode.cursor;
    }
  }

  CrossAxisAlignment get crossAxisAlignment {
    switch (this) {
      case HandleType.none:
        throw UnsupportedError('Unsupported handle type');
      case HandleType.left:
        return CrossAxisAlignment.end;
      case HandleType.right:
        return CrossAxisAlignment.start;
      case HandleType.collapsed:
        return CrossAxisAlignment.center;
    }
  }
}

// only used on Android
class AndroidCollapsedHandle extends StatelessWidget {
  const AndroidCollapsedHandle({
    super.key,
    required this.layerLink,
    required this.rect,
    this.handleColor = Colors.black,
    this.handleBallWidth = 6.0,
    this.handleWidth = 2.0,
    this.enableHapticFeedbackOnAndroid = true,
  });

  final Rect rect;
  final LayerLink layerLink;
  final Color handleColor;
  final double handleWidth;
  final double handleBallWidth;
  final bool enableHapticFeedbackOnAndroid;

  @override
  Widget build(BuildContext context) {
    // Extend the click area to make it easier to click.
    final adjustedRect = Rect.fromLTWH(
      rect.left - 2 * (handleBallWidth),
      rect.top,
      rect.width + 4 * (handleBallWidth),
      // Enable clicking in the handle area outside the stack.
      // https://github.com/flutter/flutter/issues/75747
      rect.height + 2 * handleBallWidth,
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
              child: _AndroidDragHandle(
                handleHeight: adjustedRect.height,
                handleType: HandleType.collapsed,
                handleColor: handleColor,
                handleWidth: adjustedRect.width,
                handleBallWidth: handleBallWidth,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MobileSelectionArea extends StatelessWidget {
  const MobileSelectionArea({
    super.key,
    required this.layerLink,
    required this.rect,
    this.handleType = HandleType.none,
    this.handleColor = Colors.black,
    this.handleBallWidth = 6.0,
    this.handleWidth = 2.0,
    this.enableHapticFeedbackOnAndroid = true,
  });

  final Rect rect;
  final LayerLink layerLink;
  final HandleType handleType;
  final Color handleColor;
  final double handleWidth;
  final double handleBallWidth;
  final bool enableHapticFeedbackOnAndroid;

  @override
  Widget build(BuildContext context) {
    assert(handleType != HandleType.collapsed);

    var adjustedRect = rect;
    if (handleType != HandleType.none) {
      if (Platform.isIOS) {
        // on iOS, the cursor will still be visible if the selection is not collapsed.
        // So, adding a threshold padding to avoid row overflow.
        const threshold = 0.25;
        adjustedRect = Rect.fromLTWH(
          rect.left - 2 * (handleWidth + threshold),
          rect.top - handleBallWidth,
          rect.width + 4 * (handleWidth + threshold),
          rect.height + 2 * handleBallWidth,
        );
      } else if (Platform.isAndroid) {
        // on Android, normally the cursor will be hidden if the selection is not collapsed.
        // Extend the click area to make it easier to click.
        adjustedRect = Rect.fromLTWH(
          rect.left - 2 * (handleBallWidth),
          rect.top,
          rect.width + 4 * (handleBallWidth),
          // Enable clicking in the handle area outside the stack.
          // https://github.com/flutter/flutter/issues/75747
          rect.height + 2 * handleBallWidth,
        );
      }
    }
    return Positioned.fromRect(
      rect: adjustedRect,
      child: CompositedTransformFollower(
        link: layerLink,
        offset: adjustedRect.topLeft,
        showWhenUnlinked: false,
        child: _MobileSelectionWithHandles(
          handleType: handleType,
          handleColor: handleColor,
          handleHeight: adjustedRect.height,
          handleWidth: handleWidth,
          handleBallWidth: handleBallWidth,
        ),
      ),
    );
  }
}

class _MobileSelectionWithHandles extends StatelessWidget {
  const _MobileSelectionWithHandles({
    required this.handleType,
    this.handleColor = Colors.black,
    this.handleWidth = 2.0,
    required this.handleHeight,
    required this.handleBallWidth,
  });

  final HandleType handleType;
  final Color handleColor;
  final double handleWidth;
  final double handleHeight;
  final double handleBallWidth;

  @override
  Widget build(BuildContext context) {
    assert(handleType != HandleType.collapsed);

    final Widget child;
    if (handleType != HandleType.none) {
      final offset = Platform.isIOS ? -handleWidth : 0.0;
      child = Stack(
        clipBehavior: Clip.none,
        children: [
          if (handleType == HandleType.left)
            Positioned(
              left: offset,
              child: _DragHandle(
                handleColor: handleColor,
                handleWidth: handleWidth,
                handleBallWidth: handleBallWidth,
                handleHeight: handleHeight,
                handleType: HandleType.left,
              ),
            ),
          if (handleType == HandleType.right)
            Positioned(
              right: offset,
              child: _DragHandle(
                handleColor: handleColor,
                handleWidth: handleWidth,
                handleBallWidth: handleBallWidth,
                handleHeight: handleHeight,
                handleType: HandleType.right,
              ),
            ),
        ],
      );
    } else {
      child = const SizedBox.shrink();
    }
    return child;
  }
}

abstract class _IDragHandle extends StatelessWidget {
  const _IDragHandle({
    required this.handleHeight,
    this.handleColor = Colors.black,
    this.handleWidth = 2.0,
    this.handleBallWidth = 6.0,
    required this.handleType,
  });

  final Color handleColor;
  final double handleWidth;
  final double handleHeight;
  final double handleBallWidth;
  final HandleType handleType;
}

class _DragHandle extends _IDragHandle {
  const _DragHandle({
    required super.handleHeight,
    super.handleColor,
    super.handleWidth,
    super.handleBallWidth,
    required super.handleType,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return _IOSDragHandle(
        handleHeight: handleHeight,
        handleColor: handleColor,
        handleWidth: handleWidth,
        handleBallWidth: handleBallWidth,
        handleType: handleType,
      );
    } else if (Platform.isAndroid) {
      return _AndroidDragHandle(
        handleHeight: handleHeight,
        handleColor: handleColor,
        handleWidth: handleWidth,
        handleBallWidth: handleBallWidth,
        handleType: handleType,
      );
    }
    throw UnsupportedError('Unsupported platform');
  }
}

class _IOSDragHandle extends _IDragHandle {
  const _IOSDragHandle({
    required super.handleHeight,
    super.handleColor,
    super.handleWidth,
    super.handleBallWidth,
    required super.handleType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        if (handleType == HandleType.left)
          Container(
            width: handleBallWidth,
            height: handleBallWidth,
            decoration: BoxDecoration(
              color: handleColor,
              shape: BoxShape.circle,
            ),
          ),
        if (handleType == HandleType.right)
          SizedBox(
            width: handleBallWidth,
            height: handleBallWidth,
          ),
        Container(
          width: handleWidth,
          color: handleColor,
          height: handleHeight - 2.0 * handleBallWidth,
        ),
        if (handleType == HandleType.right)
          Container(
            width: handleBallWidth,
            height: handleBallWidth,
            decoration: BoxDecoration(
              color: handleColor,
              shape: BoxShape.circle,
            ),
          ),
        if (handleType == HandleType.left)
          SizedBox(
            width: handleBallWidth,
            height: handleBallWidth,
          ),
      ],
    );
  }
}

// ignore: must_be_immutable
class _AndroidDragHandle extends _IDragHandle {
  _AndroidDragHandle({
    required super.handleHeight,
    super.handleColor,
    super.handleWidth,
    super.handleBallWidth,
    required super.handleType,
  });

  Selection? selection;

  @override
  Widget build(BuildContext context) {
    final editorState = context.read<EditorState>();
    Widget child = SizedBox(
      width: handleWidth,
      height: handleHeight - 2.0 * handleBallWidth,
    );

    if (handleType == HandleType.none) {
      return child;
    }

    final ballWidth = handleBallWidth * 2.0;

    child = GestureDetector(
      key: handleType.key,
      behavior: HitTestBehavior.opaque,
      dragStartBehavior: DragStartBehavior.down,
      onPanStart: (details) {
        selection = editorState.service.selectionService.onPanStart(
          details.translate(0, -ballWidth),
          handleType.dragMode,
        );
      },
      onPanUpdate: (details) {
        final selection = editorState.service.selectionService.onPanUpdate(
          details.translate(0, -ballWidth),
          handleType.dragMode,
        );
        if (this.selection != selection) {
          HapticFeedback.selectionClick();
        }
        this.selection = selection;
      },
      onPanEnd: (details) {
        editorState.service.selectionService.onPanEnd(
          details,
          handleType.dragMode,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: handleType.crossAxisAlignment,
        children: [
          child,
          if (handleType == HandleType.collapsed)
            Transform.rotate(
              angle: pi / 4.0,
              child: Container(
                width: ballWidth,
                height: ballWidth,
                decoration: BoxDecoration(
                  color: handleColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(handleBallWidth),
                    bottomLeft: Radius.circular(handleBallWidth),
                    bottomRight: Radius.circular(handleBallWidth),
                  ),
                ),
              ),
            ),
          if (handleType == HandleType.left)
            Container(
              width: ballWidth,
              height: ballWidth,
              decoration: BoxDecoration(
                color: handleColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(handleBallWidth),
                  bottomLeft: Radius.circular(handleBallWidth),
                  bottomRight: Radius.circular(handleBallWidth),
                ),
              ),
            ),
          if (handleType == HandleType.right)
            Container(
              width: ballWidth,
              height: ballWidth,
              decoration: BoxDecoration(
                color: handleColor,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(handleBallWidth),
                  bottomLeft: Radius.circular(handleBallWidth),
                  bottomRight: Radius.circular(handleBallWidth),
                ),
              ),
            ),
        ],
      ),
    );

    // use it to debug the handle area.
    // if (kDebugMode) {
    //   child = ColoredBox(
    //     color: Colors.red.withOpacity(0.5),
    //     child: child,
    //   );
    // }

    return child;
  }
}

extension on DragStartDetails {
  DragStartDetails translate(double dx, double dy) {
    return DragStartDetails(
      sourceTimeStamp: sourceTimeStamp,
      globalPosition: Offset(globalPosition.dx + dx, globalPosition.dy + dy),
      localPosition: Offset(localPosition.dx + dx, localPosition.dy + dy),
    );
  }
}

extension on DragUpdateDetails {
  DragUpdateDetails translate(double dx, double dy) {
    return DragUpdateDetails(
      sourceTimeStamp: sourceTimeStamp,
      globalPosition: Offset(globalPosition.dx + dx, globalPosition.dy + dy),
      localPosition: Offset(localPosition.dx + dx, localPosition.dy + dy),
      delta: Offset(delta.dx + dx, delta.dy + dy),
      primaryDelta: primaryDelta,
    );
  }
}
