import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

const blockComponentBackgroundColor = 'bgColor';

mixin BackgroundColorMixin {
  Node get node;

  Color get backgroundColor {
    final colorString =
        node.attributes[blockComponentBackgroundColor] as String?;
    if (colorString == null) {
      return Colors.transparent;
    }
    return colorString.toColor();
  }
}
