import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/shortcuts/character_shortcut_event.dart';
import 'package:flutter/services.dart';

Future<void> onInsert(
  TextEditingDeltaInsertion insertion,
  EditorState editorState,
  List<CharacterShortcutEvent> characterShortcutEvents,
) async {
  Log.input.debug('onInsert: $insertion');

  // character events
  final character = insertion.textInserted;
  if (character.length == 1) {
    final execution = await _executeCharacterShortcutEvent(
      editorState,
      character,
      characterShortcutEvents,
    );
    if (execution) {
      return;
    }
  }

  final selection = editorState.selection;
  if (selection == null) {
    return;
  }

  // IME
  // single line
  if (selection.isCollapsed) {
    final node = editorState.selectionService.currentSelectedNodes.first;
    assert(node.delta != null);

    final transaction = editorState.transaction
      ..insertText(
        node,
        insertion.insertionOffset,
        insertion.textInserted,
      );
    return editorState.apply(transaction);
  } else {
    throw UnimplementedError();
  }
}

Future<bool> _executeCharacterShortcutEvent(
  EditorState editorState,
  String character,
  List<CharacterShortcutEvent> characterShortcutEvents,
) async {
  for (final shortcutEvent in characterShortcutEvents) {
    if (shortcutEvent.character == character &&
        await shortcutEvent.handler(editorState)) {
      return true;
    }
  }
  return false;
}
