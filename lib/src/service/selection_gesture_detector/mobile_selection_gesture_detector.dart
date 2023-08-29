import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Because the flutter's [DoubleTapGestureRecognizer] will block the [TapGestureRecognizer]
/// for a while. So we need to implement our own GestureDetector.
class MobileSelectionGestureDetector extends StatefulWidget {
  const MobileSelectionGestureDetector({
    Key? key,
    this.child,
    this.onTapUp,
    this.onTap,
    this.onDoubleTapDown,
    this.onDoubleTap,
    this.onPanDown,
    this.onPanUpdate,
  }) : super(key: key);

  @override
  State<MobileSelectionGestureDetector> createState() =>
      MobileSelectionGestureDetectorState();

  final Widget? child;

  final GestureTapUpCallback? onTapUp;
  final GestureTapCallback? onTap;
  final GestureTapDownCallback? onDoubleTapDown;
  final GestureDoubleTapCallback? onDoubleTap;
  final GestureDragDownCallback? onPanDown;
  final GestureDragUpdateCallback? onPanUpdate;
}

class MobileSelectionGestureDetectorState
    extends State<MobileSelectionGestureDetector> {
  @override
  Widget build(BuildContext context) {
    // TODO(yijing):  Needs to refactor to add triple tap guesture, temporarily use GestureDetector here
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      // onTapDown: (tapdetail) => Log.selection.debug(
      //   'onTapDown global: ${tapdetail.globalPosition} local :${tapdetail.localPosition} }',
      // ),
      onTapUp: widget.onTapUp,
      onTap: widget.onTap,
      onDoubleTapDown: widget.onDoubleTapDown,
      onDoubleTap: widget.onDoubleTap,
      onPanUpdate: widget.onPanUpdate,
      onPanDown: widget.onPanDown,
      // onPanEnd: (details) => Log.selection.debug(
      //   'onPanEnd velocity: ${details.velocity}, local :${details.primaryVelocity}',
      // ),
      // onLongPress: () {
      //   Log.selection.debug('onLongPress');
      // },
      child: widget.child,
    );
  }
}
