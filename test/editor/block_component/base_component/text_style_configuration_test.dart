import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TextStyleConfiguration tests', () {
    test('copyWith', () {
      TextStyleConfiguration config = const TextStyleConfiguration();
      expect(config.text.fontSize, 16);

      config = config.copyWith(text: config.text.copyWith(fontSize: 24.0));
      expect(config.text.fontSize, 24.0);
    });
  });
}
