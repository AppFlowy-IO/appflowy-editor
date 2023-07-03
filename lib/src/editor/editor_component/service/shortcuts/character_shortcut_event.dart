import 'package:appflowy_editor/appflowy_editor.dart';

typedef CharacterShortcutEventHandler = Future<bool> Function(
  EditorState editorState,
);

/// Defines the implementation of shortcut event based on character.
class CharacterShortcutEvent {
  CharacterShortcutEvent({
    required this.key,
    required this.character,
    required this.handler,
  }) {
    assert(character.length == 1);
  }

  /// The unique key.
  ///
  /// Usually, uses the description as the key.
  final String key;

  /// The character to trigger the shortcut event.
  ///
  /// It must be a single character.
  String character;

  //// The handler to handle the shortcut event.
  final CharacterShortcutEventHandler handler;

  void updateCharacter(String newCharacter) {
    assert(newCharacter.length == 1);
    character = newCharacter;
  }

  Future<bool> execute(EditorState editorState) async {
    return handler(editorState);
  }

  CharacterShortcutEvent copyWith({
    String? key,
    String? character,
    CharacterShortcutEventHandler? handler,
  }) {
    return CharacterShortcutEvent(
      key: key ?? this.key,
      character: character ?? this.character,
      handler: handler ?? this.handler,
    );
  }

  @override
  String toString() =>
      'CharacterShortcutEvent(key: $key, character: $character, handler: $handler)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CharacterShortcutEvent &&
        other.key == key &&
        other.character == character &&
        other.handler == handler;
  }

  @override
  int get hashCode => key.hashCode ^ character.hashCode ^ handler.hashCode;
}
