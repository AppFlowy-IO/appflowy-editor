import 'package:appflowy_editor/appflowy_editor.dart';

Future<bool> executeCharacterShortcutEvent(
  EditorState editorState,
  String? character,
  List<CharacterShortcutEvent> characterShortcutEvents,
) async {
  if (character?.length != 1) {
    return false;
  }

  for (final shortcutEvent in characterShortcutEvents) {
    if (shortcutEvent.character == character &&
        await shortcutEvent.handler(editorState)) {
      return true;
    }
  }

  return false;
}
