import 'dart:io';
import 'dart:math';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/selection/mobile_selection_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

GlobalKey _leftHandleKey = GlobalKey();
GlobalKey _rightHandleKey = GlobalKey();
GlobalKey _collapsedHandleKey = GlobalKey();

enum HandleType {
  none,
  left,
  right,
  collapsed;

  MobileSelectionDragMode get dragMode {
    switch (this) {
      case HandleType.none:
        throw UnsupportedError('Unsupported handle type');
      case HandleType.left:
        return MobileSelectionDragMode.leftSelectionHandle;
      case HandleType.right:
        return MobileSelectionDragMode.rightSelectionHandle;
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

  GlobalKey get key {
    switch (this) {
      case HandleType.none:
        throw UnsupportedError('Unsupported handle type');
      case HandleType.left:
        return _leftHandleKey;
      case HandleType.right:
        return _rightHandleKey;
      case HandleType.collapsed:
        return _collapsedHandleKey;
    }
  }
}

abstract class _IDragHandle extends StatelessWidget {
  const _IDragHandle({
    super.key,
    required this.handleHeight,
    this.handleColor = Colors.black,
    this.handleWidth = 2.0,
    this.handleBallWidth = 6.0,
    this.debugPaintSizeEnabled = false,
    required this.handleType,
  });

  final Color handleColor;
  final double handleWidth;
  final double handleHeight;
  final double handleBallWidth;
  final HandleType handleType;
  final bool debugPaintSizeEnabled;
}

class DragHandle extends _IDragHandle {
  const DragHandle({
    super.key,
    required super.handleHeight,
    super.handleColor,
    super.handleWidth,
    super.handleBallWidth,
    required super.handleType,
    super.debugPaintSizeEnabled,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (Platform.isIOS) {
      child = _IOSDragHandle(
        handleHeight: handleHeight,
        handleColor: handleColor,
        handleWidth: handleWidth,
        handleBallWidth: handleBallWidth,
        handleType: handleType,
        debugPaintSizeEnabled: debugPaintSizeEnabled,
      );
    } else if (Platform.isAndroid) {
      child = _AndroidDragHandle(
        handleHeight: handleHeight,
        handleColor: handleColor,
        handleWidth: handleWidth,
        handleBallWidth: handleBallWidth,
        handleType: handleType,
        debugPaintSizeEnabled: debugPaintSizeEnabled,
      );
    } else {
      throw UnsupportedError('Unsupported platform');
    }

    if (debugPaintSizeEnabled) {
      child = ColoredBox(
        color: Colors.red.withOpacity(0.5),
        child: child,
      );
    }

    if (handleType != HandleType.none && handleType != HandleType.collapsed) {
      final offset = Platform.isIOS ? -handleWidth : 0.0;
      child = Stack(
        clipBehavior: Clip.none,
        children: [
          if (handleType == HandleType.left)
            Positioned(
              left: offset,
              child: child,
            ),
          if (handleType == HandleType.right)
            Positioned(
              right: offset,
              child: child,
            ),
        ],
      );
    }

    return child;
  }
}

class _IOSDragHandle extends _IDragHandle {
  const _IOSDragHandle({
    required super.handleHeight,
    super.handleColor,
    super.handleWidth,
    super.handleBallWidth,
    required super.handleType,
    super.debugPaintSizeEnabled,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (handleType == HandleType.collapsed) {
      child = Container(
        key: handleType.key,
        width: handleWidth,
        color: handleColor,
        height: handleHeight,
      );
    } else {
      child = Column(
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

    final editorState = context.read<EditorState>();
    final ballWidth = handleBallWidth;
    double offset = 0.0;
    if (handleType == HandleType.left) {
      offset = ballWidth;
    } else if (handleType == HandleType.right) {
      offset = -ballWidth;
    }

    child = GestureDetector(
      behavior: HitTestBehavior.opaque,
      dragStartBehavior: DragStartBehavior.down,
      onPanStart: (details) {
        editorState.service.selectionService.onPanStart(
          details.translate(0, offset),
          handleType.dragMode,
        );
      },
      onPanUpdate: (details) {
        editorState.service.selectionService.onPanUpdate(
          details.translate(0, offset),
          handleType.dragMode,
        );
      },
      onPanEnd: (details) {
        editorState.service.selectionService.onPanEnd(
          details,
          handleType.dragMode,
        );
      },
      child: child,
    );

    return child;
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
    super.debugPaintSizeEnabled,
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

    child = Column(
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
    );

    child = GestureDetector(
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
      child: child,
    );

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
