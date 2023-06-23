import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  group('character shortcut event', () {
    late CharacterShortcutEvent shortcutEvent;

    setUp(() {
      shortcutEvent = CharacterShortcutEvent(
        key: 'test',
        character: 'a',
        handler: (editorState) async {
          return true;
        },
      );
    });

    test('update character of character shortcut event', () async {
      expect(shortcutEvent.character, 'a');
      shortcutEvent.updateCharacter('b');
      expect(shortcutEvent.character, 'b');
    });
    test('copyWith should create a new instance with updated properties', () {
      final newShortcutEvent = shortcutEvent.copyWith(key: 'newKey');

      // Test if the property changed
      expect(newShortcutEvent.key, 'newKey');

      // Test if the unchanged properties remain intact
      expect(newShortcutEvent.character, 'a');
      expect(newShortcutEvent.handler, equals(shortcutEvent.handler));
    });

    test('execute should call the handler', () async {
      var handlerCalled = false;
      var handler = (EditorState state) async {
        handlerCalled = true;
        return true;
      };

      final myEvent =
          CharacterShortcutEvent(key: "test", character: "a", handler: handler);

      await myEvent.execute(EditorState.empty());

      expect(handlerCalled, true);
    });

    test('equality check should compare properties correctly', () async {
      var handler = (EditorState state) async {
        return true;
      };

      final shortcutOne =
          CharacterShortcutEvent(key: "test", character: "a", handler: handler);

      final shortcutTwo =
          CharacterShortcutEvent(key: 'test', character: 'a', handler: handler);

      expect(true, shortcutOne == shortcutTwo);
    });

    test('hashCode should return the correct hash code', () {
      final hashCode = shortcutEvent.key.hashCode ^
          shortcutEvent.character.hashCode ^
          shortcutEvent.handler.hashCode;

      expect(shortcutEvent.hashCode, hashCode);
    });
  });
}
