import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

mixin BlockComponentBackgroundColorMixin {
  Node get node;

  Color get backgroundColor {
    final colorString =
        node.attributes[blockComponentBackgroundColor] as String?;
    if (colorString == null) {
      return Colors.transparent;
    }
    return colorString.toColor() ?? Colors.transparent;
  }
}
