import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_character_shortcut.dart';

void main() async {
  group(
    'divider_character_shortcut.dart',
    () {
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
          (result, before, after, editorState) {
            expect(result, true);
            expect(after.delta, null);
            expect(after.type, DividerBlockKeys.type);
            expect(after.next, isNotNull);
            expect(after.next!.type, ParagraphBlockKeys.type);
            final nextNode = editorState.getNodeAtPath(after.next!.path);
            expect(nextNode!.path, editorState.selection!.end.path);
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
          (result, before, after, editorState) {
            expect(result, true);
            expect(after.delta, null);
            expect(after.type, DividerBlockKeys.type);
          },
          text: text,
        );
      });

      // Before
      //  __
      // After
      // [divider]
      test('___ to divider', () async {
        const text = '';
        testFormatCharacterShortcut(
          convertUnderscoreToDivider,
          '__',
          2,
          (result, before, after, editorState) {
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
