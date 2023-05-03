import 'package:appflowy_editor/src/editor/block_component/base_component/widget/ignore_parent_pointer.dart';
import 'package:flutter/material.dart';

class FullScreenOverlayEntry {
  FullScreenOverlayEntry({
    required this.offset,
    required this.builder,
    this.tapToDismiss = true,
  });

  final Offset offset;
  final Widget Function(
    BuildContext context,
    Size size,
  ) builder;
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
                  top: offset.dy,
                  left: offset.dx,
                  child: IgnoreParentPointer(
                    child: Material(
                      child: builder(context, size),
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
