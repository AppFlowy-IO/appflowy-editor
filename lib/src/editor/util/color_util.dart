import 'package:flutter/material.dart';

extension ColorExtension on String {
  Color? toColor() {
    var hexString = replaceFirst('0x', '');
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    final value = int.tryParse(buffer.toString(), radix: 16);
    return value != null ? Color(value) : null;
  }

  Color? tryToColor() {
    if (startsWith('#') || startsWith('0x')) {
      return toColor();
    }

    final reg = RegExp(r'rgba\((\d+),(\d+),(\d+),([\d.]+)\)');
    final match = reg.firstMatch(replaceAll(' ', ''));
    if (match == null) {
      return null;
    }

    if (match.groupCount < 4) {
      return null;
    }
    final redStr = match.group(1);
    final greenStr = match.group(2);
    final blueStr = match.group(3);
    final alphaStr = match.group(4);

    final red = redStr != null ? int.tryParse(redStr) : null;
    final green = greenStr != null ? int.tryParse(greenStr) : null;
    final blue = blueStr != null ? int.tryParse(blueStr) : null;
    final alpha = alphaStr != null ? double.tryParse(alphaStr) ?? 1.0 : 1.0;

    if (red == null || green == null || blue == null) {
      return null;
    }

    return Color.fromARGB((alpha * 255).toInt(), red, green, blue);
  }
}

extension HexExtension on Color {
  String toHex() {
    return '0x${value.toRadixString(16)}';
  }
}
