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

  String character;

  final CharacterShortcutEventHandler handler;

  Future<bool> execute(EditorState editorState) async {
    return handler(editorState);
  }

  @override
  String toString() =>
      'CharacterShortcutEvent(key: $key, character: $character, handler: $handler)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ShortcutEvent &&
        other.key == key &&
        other.character == character &&
        other.handler == handler;
  }

  @override
  int get hashCode => key.hashCode ^ character.hashCode ^ handler.hashCode;
}
