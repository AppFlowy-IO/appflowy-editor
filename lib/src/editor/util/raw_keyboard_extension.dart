import 'package:flutter/services.dart';

extension RawKeyboardExtension on RawKeyboard {
  bool get isShiftPressed => RawKeyboard.instance.keysPressed.any(
        (element) => [
          LogicalKeyboardKey.shift,
          LogicalKeyboardKey.shiftLeft,
          LogicalKeyboardKey.shiftRight,
        ].contains(element),
      );
}
