import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Because the flutter's [DoubleTapGestureRecognizer] will block the [TapGestureRecognizer]
/// for a while. So we need to implement our own GestureDetector.
class MobileSelectionGestureDetector extends StatefulWidget {
  const MobileSelectionGestureDetector({
    super.key,
    this.child,
    this.onTapUp,
    this.onDoubleTapUp,
    this.onTripleTapUp,
    this.onSecondaryTapUp,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
  });

  @override
  State<MobileSelectionGestureDetector> createState() =>
      MobileSelectionGestureDetectorState();

  final Widget? child;

  final GestureTapUpCallback? onTapUp;
  final GestureTapUpCallback? onDoubleTapUp;
  final GestureTapUpCallback? onTripleTapUp;
  final GestureTapUpCallback? onSecondaryTapUp;
  final GestureDragStartCallback? onPanStart;
  final GestureDragUpdateCallback? onPanUpdate;
  final GestureDragEndCallback? onPanEnd;
}

class MobileSelectionGestureDetectorState
    extends State<MobileSelectionGestureDetector> {
  bool _isDoubleTap = false;
  Timer? _doubleTapTimer;
  int _tripleTapCount = 0;
  Timer? _tripleTapTimer;

  final kTripleTapTimeout = const Duration(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      behavior: HitTestBehavior.opaque,
      gestures: {
        PanGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(
          () => PanGestureRecognizer(
            supportedDevices: {
              //   // https://docs.flutter.dev/release/breaking-changes/trackpad-gestures#for-gesture-interactions-not-suitable-for-trackpad-usage
              //   PointerDeviceKind.trackpad,
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.stylus,
              PointerDeviceKind.invertedStylus,
            },
          ),
          (recognizer) {
            recognizer
              ..dragStartBehavior = DragStartBehavior.down
              ..onStart = widget.onPanStart
              ..onUpdate = widget.onPanUpdate
              ..onEnd = widget.onPanEnd;
          },
        ),
        TapGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
          () => TapGestureRecognizer(),
          (recognizer) {
            // use tap up instead of tap down to avoid this gesture detector
            //  being responded before the pan gesture detector.
            recognizer.onTapUp = _tapDownDelegate;
            recognizer.onSecondaryTapUp = widget.onSecondaryTapUp;
          },
        ),
      },
      child: widget.child,
    );
  }

  void _tapDownDelegate(TapUpDetails tapDownDetails) {
    if (_tripleTapCount == 2) {
      _tripleTapCount = 0;
      _tripleTapTimer?.cancel();
      _tripleTapTimer = null;
      if (widget.onTripleTapUp != null) {
        widget.onTripleTapUp!(tapDownDetails);
      }
    } else if (_isDoubleTap) {
      _isDoubleTap = false;
      _doubleTapTimer?.cancel();
      _doubleTapTimer = null;
      if (widget.onDoubleTapUp != null) {
        widget.onDoubleTapUp!(tapDownDetails);
      }
      _tripleTapCount++;
    } else {
      if (widget.onTapUp != null) {
        widget.onTapUp!(tapDownDetails);
      }

      _isDoubleTap = true;
      _doubleTapTimer?.cancel();
      _doubleTapTimer = Timer(kDoubleTapTimeout, () {
        _isDoubleTap = false;
        _doubleTapTimer = null;
      });

      _tripleTapCount = 1;
      _tripleTapTimer?.cancel();
      _tripleTapTimer = Timer(kTripleTapTimeout, () {
        _tripleTapCount = 0;
        _tripleTapTimer = null;
      });
    }
  }

  @override
  void dispose() {
    _doubleTapTimer?.cancel();
    _tripleTapTimer?.cancel();
    super.dispose();
  }
}
