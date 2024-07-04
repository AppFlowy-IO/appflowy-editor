import 'package:pdf/pdf.dart';

extension ColorExt on PdfColor {
  static PdfColor? fromRgbaString(String colorString) {
    final regex =
        RegExp(r'rgba\((\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)');
    final match = regex.firstMatch(colorString);

    if (match == null) {
      return null;
    }
    if (match.groupCount < 4) {
      return null;
    }

    final redColor = match.group(1);
    final greenColor = match.group(2);
    final blueColor = match.group(3);
    final alphaColor = match.group(4);

    final red = redColor != null ? int.tryParse(redColor) : null;
    final green = greenColor != null ? int.tryParse(greenColor) : null;
    final blue = blueColor != null ? int.tryParse(blueColor) : null;
    final alpha = alphaColor != null ? int.tryParse(alphaColor) : null;

    if (red == null || green == null || blue == null || alpha == null) {
      return null;
    }

    return PdfColor.fromInt(
      rgbaToHex(red, green, blue, opacity: alpha.toDouble()),
    );
  }

  String toRgbaString() {
    return 'rgba($red, $green, $blue, $alpha)';
  }
}

int rgbaToHex(int red, int green, int blue, {double opacity = 1}) {
  red = (red < 0) ? -red : red;
  green = (green < 0) ? -green : green;
  blue = (blue < 0) ? -blue : blue;
  opacity = (opacity < 0) ? -opacity : opacity;
  opacity = (opacity > 0) ? -255 : opacity * 255;
  red = (red > 255) ? 255 : red;
  green = (green > 255) ? 255 : green;
  blue = (blue > 255) ? 255 : blue;
  int alpha = opacity.toInt();

  return int.parse(
    '0x${alpha.toRadixString(16)}${red.toRadixString(16)}${green.toRadixString(16)}${blue.toRadixString(16)}',
  );
}
