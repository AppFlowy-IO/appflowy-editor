import 'package:appflowy_editor/src/editor/block_component/base_component/widget/ignore_parent_pointer.dart';
import 'package:flutter/material.dart';

class FullScreenOverlayEntry {
  FullScreenOverlayEntry({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.builder,
    this.tapToDismiss = true,
  });

  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final WidgetBuilder builder;
  final bool tapToDismiss;

  OverlayEntry? _entry;

  OverlayEntry build() {
    _entry?.remove();
    _entry = OverlayEntry(
      builder: (context) {
        final size = MediaQuery.of(context).size;
        return SizedBox.fromSize(
          size: size,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (tapToDismiss) {
                // remove this from the overlay when tapped the opaque layer
                _entry?.remove();
                _entry = null;
              }
            },
            child: Stack(
              children: [
                Positioned(
                  top: top,
                  bottom: bottom,
                  left: left,
                  right: right,
                  child: IgnoreParentPointer(
                    child: Material(
                      // Avoid background color behind the child, so the child can fully control the overlay style
                      color: Colors.transparent,
                      child: builder(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    return _entry!;
  }
}
