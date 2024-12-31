import 'package:appflowy_editor/appflowy_editor.dart';

Future<bool> executeCharacterShortcutEvent(
  EditorState editorState,
  String? character,
  List<CharacterShortcutEvent> characterShortcutEvents,
) async {
  // if the character is a space + enter, we should execute the enter event
  if (character == ' \n') {
    character = '\n';
  }

  if (character?.length != 1) {
    return false;
  }

  for (final shortcutEvent in characterShortcutEvents) {
    if (shortcutEvent.character == character &&
        await shortcutEvent.handler(editorState)) {
      AppFlowyEditorLog.input.debug(
        'keyboard service - handled by character shortcut event: $shortcutEvent',
      );
      return true;
    }
  }

  return false;
}
