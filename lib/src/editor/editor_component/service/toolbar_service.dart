import 'package:flutter/material.dart' hide Overlay, OverlayEntry;

abstract class AppFlowyToolbarService {
  /// Show the toolbar widget beside the offset.
  void showInOffset(
    Offset offset,
    Alignment alignment,
    LayerLink layerLink,
  );

  /// Hide the toolbar widget.
  void hide();

  /// Trigger the specified handler.
  bool triggerHandler(String id);
}
