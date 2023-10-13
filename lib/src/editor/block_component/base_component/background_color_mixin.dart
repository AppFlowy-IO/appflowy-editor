import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

/// If you want to customize the logic of how to convert a color string to a
///   [Color], you can set this variable.
typedef BlockComponentBackgroundColorDecorator = Color? Function(
  Node node,
  String colorString,
);
BlockComponentBackgroundColorDecorator? blockComponentBackgroundColorDecorator;

mixin BlockComponentBackgroundColorMixin {
  Node get node;

  Color get backgroundColor {
    final colorString =
        node.attributes[blockComponentBackgroundColor] as String?;
    if (colorString == null) {
      return Colors.transparent;
    }

    return blockComponentBackgroundColorDecorator?.call(
          node,
          colorString,
        ) ??
        colorString.tryToColor() ??
        Colors.transparent;
  }
}
