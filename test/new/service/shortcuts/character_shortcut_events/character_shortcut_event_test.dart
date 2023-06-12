import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('character shortcut event', () {
    test('update character_shortcut_event\'s character', () async {
      final event = CharacterShortcutEvent(
        key: 'test',
        character: 'a',
        handler: (editorState) async => true,
      );
      expect(event.character, 'a');
      event.updateCharacter('b');
      expect(event.character, 'b');
    });

    test('copy character_shortcut_event', () async {
      final event = CharacterShortcutEvent(
        key: 'test',
        character: 'a',
        handler: (editorState) async => true,
      );
      final newEvent = event.copyWith(
        character: 'b',
        handler: (editorState) async => false,
      );
      expect(newEvent.character, 'b');
      expect(await newEvent.execute(EditorState.blank()), false);
    });
  });
}
