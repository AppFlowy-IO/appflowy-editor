import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../util/util.dart';
import '../test_character_shortcut.dart';

void main() async {
  group(
    'divider_character_shortcut.dart',
    () {
      setUpAll(() {
        if (kDebugMode) {
          activateLog();
        }
      });

      tearDownAll(
        () {
          if (kDebugMode) {
            deactivateLog();
          }
        },
      );

      // Before
      // --
      // After
      // [divider]
      test('--- to divider', () async {
        const text = '';
        testFormatCharacterShortcut(
          convertMinusesToDivider,
          '--',
          2,
          (result, before, after) {
            expect(result, true);
            expect(after.delta, null);
            expect(after.type, DividerBlockKeys.type);
          },
          text: text,
        );
      });

      // Before
      // **
      // After
      // [divider]
      test('*** to divider', () async {
        const text = '';
        testFormatCharacterShortcut(
          convertStarsToDivider,
          '**',
          2,
          (result, before, after) {
            expect(result, true);
            expect(after.delta, null);
            expect(after.type, DividerBlockKeys.type);
          },
          text: text,
        );
      });
    },
  );
}
