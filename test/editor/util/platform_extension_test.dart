import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('platform extension', () {
    test('test safe platform judgement', () {
      if (!kIsWeb && Platform.isLinux) {
        expect(PlatformExtension.isLinux, true);
        expect(PlatformExtension.isWebOnLinux, false);
      }

      if (!kIsWeb && Platform.isWindows) {
        expect(PlatformExtension.isWindows, true);
        expect(PlatformExtension.isWebOnWindows, false);
      }

      if (!kIsWeb && Platform.isMacOS) {
        expect(PlatformExtension.isMacOS, true);
        expect(PlatformExtension.isWebOnMacOS, false);
      }
    });
  });
}
