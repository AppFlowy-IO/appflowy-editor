import 'package:flutter/material.dart';

class FullScreenOverlayEntry {
  FullScreenOverlayEntry({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.builder,
    this.tapToDismiss = true,
    this.dismissCallback,
  });

  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final WidgetBuilder builder;
  final bool tapToDismiss;
  final VoidCallback? dismissCallback;

  OverlayEntry? _entry;

  OverlayEntry build() {
    _entry?.remove();
    _entry = OverlayEntry(
      builder: (context) {
        final size = MediaQuery.of(context).size;
        return SizedBox.fromSize(
          size: size,
          child: Stack(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (tapToDismiss) {
                    // remove this from the overlay when tapped the opaque layer
                    _entry?.remove();
                    _entry = null;
                    dismissCallback?.call();
                  }
                },
              ),
              Positioned(
                top: top,
                bottom: bottom,
                left: left,
                right: right,
                child: Material(
                  // Avoid background color behind the child, so the child can fully control the overlay style
                  color: Colors.transparent,
                  child: builder(context),
                ),
              ),
            ],
          ),
        );
      },
    );
    return _entry!;
  }
}
