import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ColorExtension', () {
    test('Test RGBA color conversion', () {
      final rgba1 = 'rgba(0, 128, 255, 0.5)'.tryToColor();
      final rgba2 = 'rgba(255, 255, 0)'.tryToColor();

      expect(
        rgba1,
        equals(const Color(0x7f0080ff)),
      );
      expect(
        rgba2,
        equals(null),
      );
    });

    test('Test RGB color conversion', () {
      final rgb1 = 'rgb(255, 0, 0)'.tryToColor();
      final rgb2 = 'rgb(255, 0, 0, 255)'.tryToColor();
      expect(
        rgb1,
        equals(const Color(0xffff0000)),
      );
      expect(
        rgb2,
        equals(null),
      );
    });

    test('Test hex color conversion (0x format)', () {
      final hex1 = '0xFF00FF'.tryToColor();
      final hex2 = '0x0000FFFF'.tryToColor();
      expect(
        hex1,
        equals(const Color(0xffff00ff)),
      );
      expect(
        hex2,
        equals(const Color(0x0000FFFF)),
      );
    });

    test('Test hex color conversion (# format)', () {
      final hex1 = '#00FF00'.tryToColor();
      expect(
        hex1,
        equals(const Color(0xff00ff00)),
      );
    });
  });

  group('HexExtension', () {
    test('toHex', () {
      const color = Color.fromARGB(255, 255, 255, 255);

      expect(color.toHex(), '0xffffffff');
    });
  });
}
