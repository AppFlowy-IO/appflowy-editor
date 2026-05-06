import 'dart:math';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/selection/mobile_selection_service.dart';
import 'package:appflowy_editor/src/editor/util/platform_extension.dart';
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
    this.onDragging,
    required this.handleType,
  });

  final Color handleColor;
  final double handleWidth;
  final double handleHeight;
  final double handleBallWidth;
  final HandleType handleType;
  final bool debugPaintSizeEnabled;
  final ValueChanged<bool>? onDragging;
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
    super.onDragging,
  });

  @override
  Widget build(BuildContext context) {
    if (handleType == HandleType.none ||
        handleType == HandleType.collapsed) {
      // Collapsed handle still uses the inner per-platform widgets, which
      // build their own gesture detectors sized to the (already enlarged)
      // outer rect.
      Widget child;
      if (PlatformExtension.isIOS) {
        child = _IOSDragHandle(
          handleHeight: handleHeight,
          handleColor: handleColor,
          handleWidth: handleWidth,
          handleBallWidth: handleBallWidth,
          handleType: handleType,
          debugPaintSizeEnabled: debugPaintSizeEnabled,
          onDragging: onDragging,
        );
      } else if (PlatformExtension.isAndroid) {
        child = _AndroidDragHandle(
          handleHeight: handleHeight,
          handleColor: handleColor,
          handleWidth: handleWidth,
          handleBallWidth: handleBallWidth,
          handleType: handleType,
          debugPaintSizeEnabled: debugPaintSizeEnabled,
          onDragging: onDragging,
        );
      } else {
        throw UnsupportedError('Unsupported platform');
      }
      if (debugPaintSizeEnabled) {
        child = ColoredBox(
          color: Colors.red.withValues(alpha: 0.5),
          child: child,
        );
      }
      return child;
    }

    return _SelectionDragHandle(
      handleHeight: handleHeight,
      handleColor: handleColor,
      handleWidth: handleWidth,
      handleBallWidth: handleBallWidth,
      handleType: handleType,
      debugPaintSizeEnabled: debugPaintSizeEnabled,
      onDragging: onDragging,
    );
  }
}

/// Selection (left/right) drag handle. Owns its own gesture detector that
/// fills the entire outer touch zone (provided by [Positioned.fromRect] in
/// [MobileSelectionHandle]) and consumes both pans and taps so the editor's
/// tap recognizer below it cannot collapse the selection while the user is
/// trying to grab the handle.
class _SelectionDragHandle extends StatefulWidget {
  const _SelectionDragHandle({
    required this.handleHeight,
    required this.handleColor,
    required this.handleWidth,
    required this.handleBallWidth,
    required this.handleType,
    required this.debugPaintSizeEnabled,
    required this.onDragging,
  });

  final double handleHeight;
  final Color handleColor;
  final double handleWidth;
  final double handleBallWidth;
  final HandleType handleType;
  final bool debugPaintSizeEnabled;
  final ValueChanged<bool>? onDragging;

  @override
  State<_SelectionDragHandle> createState() => _SelectionDragHandleState();
}

class _SelectionDragHandleState extends State<_SelectionDragHandle> {
  Selection? _selection;

  @override
  Widget build(BuildContext context) {
    final editorState = context.read<EditorState>();

    Widget visual;
    if (PlatformExtension.isIOS) {
      visual = _IOSDragHandleVisual(
        handleHeight: widget.handleHeight,
        handleColor: widget.handleColor,
        handleWidth: widget.handleWidth,
        handleBallWidth: widget.handleBallWidth,
        handleType: widget.handleType,
      );
    } else if (PlatformExtension.isAndroid) {
      visual = _AndroidDragHandleVisual(
        handleColor: widget.handleColor,
        handleWidth: widget.handleWidth,
        handleHeight: widget.handleHeight,
        handleBallWidth: widget.handleBallWidth,
        handleType: widget.handleType,
      );
    } else {
      throw UnsupportedError('Unsupported platform');
    }

    if (widget.debugPaintSizeEnabled) {
      visual = ColoredBox(
        color: Colors.red.withValues(alpha: 0.5),
        child: visual,
      );
    }

    final visualEdgeOffset =
        PlatformExtension.isIOS ? -widget.handleWidth : 0.0;
    final ballWidth = widget.handleBallWidth;
    double dyOffset = 0.0;
    if (PlatformExtension.isIOS) {
      if (widget.handleType == HandleType.left) {
        dyOffset = ballWidth;
      } else if (widget.handleType == HandleType.right) {
        dyOffset = -ballWidth;
      }
    } else if (PlatformExtension.isAndroid) {
      dyOffset = -ballWidth * 2;
    }

    return RawGestureDetector(
      behavior: HitTestBehavior.opaque,
      gestures: {
        PanGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(
          () => PanGestureRecognizer(),
          (recognizer) {
            recognizer
              ..dragStartBehavior = DragStartBehavior.down
              ..onStart = (details) {
                _selection = editorState.service.selectionService.onPanStart(
                  details.translate(0, dyOffset),
                  widget.handleType.dragMode,
                );
                widget.onDragging?.call(true);
              }
              ..onUpdate = (details) {
                final newSelection =
                    editorState.service.selectionService.onPanUpdate(
                  details.translate(0, dyOffset),
                  widget.handleType.dragMode,
                );
                if (PlatformExtension.isAndroid &&
                    _selection != newSelection) {
                  HapticFeedback.selectionClick();
                }
                _selection = newSelection;
                widget.onDragging?.call(true);
              }
              ..onEnd = (details) {
                editorState.service.selectionService.onPanEnd(
                  details,
                  widget.handleType.dragMode,
                );
                widget.onDragging?.call(false);
              };
          },
        ),
        // Swallow taps inside the touch zone. The editor's tap recognizer
        // sits above us in the gesture arena; without this it wins on lift
        // and collapses the selection back to a caret. We register a no-op
        // recognizer so the inner (deeper) tap wins instead.
        TapGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
          () => TapGestureRecognizer(),
          (recognizer) {
            recognizer.onTap = () {};
          },
        ),
      },
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          if (widget.handleType == HandleType.left)
            Positioned(left: visualEdgeOffset, top: 0, child: visual),
          if (widget.handleType == HandleType.right)
            Positioned(right: visualEdgeOffset, top: 0, child: visual),
        ],
      ),
    );
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
    super.onDragging,
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
        onDragging?.call(true);
      },
      onPanUpdate: (details) {
        editorState.service.selectionService.onPanUpdate(
          details.translate(0, offset),
          handleType.dragMode,
        );
        onDragging?.call(true);
      },
      onPanEnd: (details) {
        editorState.service.selectionService.onPanEnd(
          details,
          handleType.dragMode,
        );
        onDragging?.call(false);
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
    super.onDragging,
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
        onDragging?.call(true);
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
        onDragging?.call(true);
      },
      onPanEnd: (details) {
        editorState.service.selectionService.onPanEnd(
          details,
          handleType.dragMode,
        );
        onDragging?.call(false);
      },
      child: child,
    );

    return child;
  }
}

/// Pure visual half of [_IOSDragHandle] used by [_SelectionDragHandle] for
/// the left/right handles. Mirrors the iOS column layout (ball + bar) without
/// owning any gesture detection.
class _IOSDragHandleVisual extends StatelessWidget {
  const _IOSDragHandleVisual({
    required this.handleHeight,
    required this.handleColor,
    required this.handleWidth,
    required this.handleBallWidth,
    required this.handleType,
  });

  final double handleHeight;
  final Color handleColor;
  final double handleWidth;
  final double handleBallWidth;
  final HandleType handleType;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
          SizedBox(width: handleBallWidth, height: handleBallWidth),
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
          SizedBox(width: handleBallWidth, height: handleBallWidth),
      ],
    );
  }
}

/// Pure visual half of [_AndroidDragHandle] used by [_SelectionDragHandle] for
/// the left/right handles. Mirrors the Android column layout (bar + rounded
/// teardrop ball) without owning any gesture detection.
class _AndroidDragHandleVisual extends StatelessWidget {
  const _AndroidDragHandleVisual({
    required this.handleColor,
    required this.handleWidth,
    required this.handleHeight,
    required this.handleBallWidth,
    required this.handleType,
  });

  final Color handleColor;
  final double handleWidth;
  final double handleHeight;
  final double handleBallWidth;
  final HandleType handleType;

  @override
  Widget build(BuildContext context) {
    final ballWidth = handleBallWidth * 2.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: handleType.crossAxisAlignment,
      children: [
        SizedBox(
          width: handleWidth,
          height: handleHeight - 2.0 * handleBallWidth,
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
