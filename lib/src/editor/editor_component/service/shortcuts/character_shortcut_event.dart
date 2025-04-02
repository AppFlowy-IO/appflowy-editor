import 'package:appflowy_editor/appflowy_editor.dart';

typedef CharacterShortcutEventHandler = Future<bool> Function(
  EditorState editorState,
);

typedef CharacterShortcutEventHandlerWithCharacter = Future<bool> Function(
  EditorState editorState,
  String character,
);

/// Defines the implementation of shortcut event based on character.
class CharacterShortcutEvent {
  CharacterShortcutEvent({
    required this.key,
    required this.character,
    required this.handler,
    this.handlerWithCharacter,
    this.regExp,
  }) {
    assert(
      (regExp == null && character.length == 1) ||
          (regExp != null && character.isEmpty),
    );
  }

  /// The unique key.
  ///
  /// Usually, uses the description as the key.
  final String key;

  /// The character to trigger the shortcut event.
  ///
  /// It must be a single character.
  String character;

  /// The regExp to trigger the shortcut event
  ///
  /// It will only match for a single character
  RegExp? regExp;

  //// The handler to handle the shortcut event.
  final CharacterShortcutEventHandler handler;
  final CharacterShortcutEventHandlerWithCharacter? handlerWithCharacter;

  void updateCharacter(String newCharacter) {
    assert(newCharacter.length == 1);
    character = newCharacter;
  }

  Future<bool> execute(EditorState editorState) async {
    return handler.call(editorState);
  }

  Future<bool> executeWithCharacter(
    EditorState editorState,
    String character,
  ) async {
    return handlerWithCharacter?.call(editorState, character) ??
        handler.call(editorState);
  }

  CharacterShortcutEvent copyWith({
    String? key,
    String? character,
    CharacterShortcutEventHandler? handler,
    RegExp? regExp,
  }) {
    return CharacterShortcutEvent(
      key: key ?? this.key,
      character: character ?? this.character,
      regExp: regExp ?? this.regExp,
      handler: handler ?? this.handler,
    );
  }

  @override
  String toString() {
    return 'CharacterShortcutEvent{key: $key, character: $character, regExp: $regExp, handler: $handler}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CharacterShortcutEvent &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          character == other.character &&
          regExp == other.regExp &&
          handler == other.handler;

  @override
  int get hashCode =>
      key.hashCode ^ character.hashCode ^ regExp.hashCode ^ handler.hashCode;
}
