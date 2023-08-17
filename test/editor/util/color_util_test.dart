import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ColorExtension', () {
    test('tryToColor', () {
      const validRgba = "rgba(255, 255, 255, 1)";
      const invalidRgba = "rgba(255, 255, 0)";

      expect(validRgba.tryToColor(), const Color.fromARGB(255, 255, 255, 255));
      expect(invalidRgba.tryToColor(), null);
    });
  });

  group('HexExtension', () {
    test('toHex', () {
      const color = Color.fromARGB(255, 255, 255, 255);

      expect(color.toHex(), '0xffffffff');
    });
  });
}
