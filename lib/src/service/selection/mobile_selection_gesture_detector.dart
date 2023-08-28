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
    this.onLongPressMoveUpdate,
  }) : super(key: key);

  @override
  State<MobileSelectionGestureDetector> createState() =>
      MobileSelectionGestureDetectorState();

  final Widget? child;

  final GestureTapUpCallback? onTapUp;
  final GestureTapCallback? onTap;
  final GestureTapDownCallback? onDoubleTapDown;
  final GestureDoubleTapCallback? onDoubleTap;
  final GestureLongPressMoveUpdateCallback? onLongPressMoveUpdate;
}

class MobileSelectionGestureDetectorState
    extends State<MobileSelectionGestureDetector> {
  @override
  Widget build(BuildContext context) {
    // TODO(yijing):  Needs to refactor to add triple tap guesture, temporarily use GestureDetector here
    // All the unused gesture is filled with debuging info for now.
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (tapdetail) => Log.selection.debug(
        'onTapDown global: ${tapdetail.globalPosition} local :${tapdetail.localPosition} }',
      ),
      onTapUp: widget.onTapUp,
      onTap: widget.onTap,
      onDoubleTapDown: widget.onDoubleTapDown,
      onDoubleTap: widget.onDoubleTap,
      onDoubleTapCancel: () => Log.selection.debug('onDoubleTapCancel'),
      onLongPressMoveUpdate: widget.onLongPressMoveUpdate,
      onPanStart: (details) {
        Log.selection.debug(
          'onPanStart global: ${details.globalPosition} local :${details.localPosition} }',
        );
      },
      onPanUpdate: (details) {
        Log.selection.debug(
          'onPanUpdate global: ${details.globalPosition} local :${details.localPosition}',
        );
      },
      onPanDown: (details) => Log.selection.debug(
        'onPanDown global: ${details.globalPosition} local :${details.localPosition} }',
      ),
      onPanEnd: (details) => Log.selection.debug(
        'onPanEnd velocity: ${details.velocity}, local :${details.primaryVelocity}',
      ),
      onLongPress: () {
        Log.selection.debug('onLongPress');
      },
      child: widget.child,
    );
  }
}
