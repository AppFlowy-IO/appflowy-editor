import 'package:flutter/material.dart';

extension ColorExtension on String {
  Color toColor() {
    var hexString = replaceFirst('0x', '');
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.tryParse(buffer.toString(), radix: 16) ?? 0xFFFFFFFF);
  }
}

extension HexExtension on Color {
  String toHex() {
    return value.toRadixString(16);
  }
}
