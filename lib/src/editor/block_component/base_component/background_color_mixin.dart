import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// If you want to customize the logic of how to convert a color string to a
///   [Color], you can set this variable.
typedef BlockComponentBackgroundColorDecorator = Decoration? Function(
  Node node,
  String colorString,
);
BlockComponentBackgroundColorDecorator? blockComponentDecorator;

mixin BlockComponentBackgroundColorMixin {
  Node get node;

  Decoration? get decoration {
    final colorString =
        node.attributes[blockComponentBackgroundColor] as String?;
    if (colorString == null) {
      return null;
    }

    return blockComponentDecorator?.call(
          node,
          colorString,
        ) ??
        BoxDecoration(
          color: colorString.tryToColor(),
        );
  }
}
