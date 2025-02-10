import 'package:flutter/material.dart';

extension ColorExtension on String {
  Color? tryToColor() {
    final rgbRegex = RegExp(r'^rgb\((\d+),\s*(\d+),\s*(\d+)\)$');
    final rgbaRegex = RegExp(r'^rgba\((\d+),\s*(\d+),\s*(\d+),\s*([\d.]+)\)$');
    final hexRegex = RegExp(r'^(0x|#)([0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$');

    if (rgbRegex.hasMatch(this)) {
      final match = rgbRegex.firstMatch(this);
      if (match != null && match.groupCount == 3) {
        final r = int.tryParse(match.group(1)!);
        final g = int.tryParse(match.group(2)!);
        final b = int.tryParse(match.group(3)!);
        if (r != null && g != null && b != null) {
          return Color.fromARGB(255, r, g, b);
        }
      }
    } else if (rgbaRegex.hasMatch(this)) {
      final match = rgbaRegex.firstMatch(this);
      if (match != null && match.groupCount == 4) {
        final r = int.tryParse(match.group(1)!);
        final g = int.tryParse(match.group(2)!);
        final b = int.tryParse(match.group(3)!);
        final a = double.tryParse(match.group(4)!);
        if (r != null && g != null && b != null && a != null) {
          return Color.fromARGB((a * 255).toInt(), r, g, b);
        }
      }
    } else if (hexRegex.hasMatch(this)) {
      final match = hexRegex.firstMatch(this);
      if (match != null && match.groupCount == 2) {
        final hexValue = int.tryParse(match.group(2)!, radix: 16);
        if (hexValue != null) {
          if (match.group(2)!.length == 6) {
            // 6-character hex format without alpha
            return Color(hexValue).withAlpha(255);
          } else {
            // 8-character hex format with alpha
            return Color(hexValue);
          }
        }
      }
    }

    return null; // Return null if parsing fails
  }
}

extension HexExtension on Color {
  String toHex() {
    return '0x${value.toRadixString(16)}';
  }
}
