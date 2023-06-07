import 'package:appflowy_editor/appflowy_editor.dart';
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

  var selection = editorState.selection;
  if (selection == null) {
    return;
  }

  if (!selection.isCollapsed) {
    await editorState.deleteSelection(selection);
  }

  selection = editorState.selection?.normalized;
  if (selection == null || !selection.isCollapsed) {
    return;
  }

  // IME
  // single line
  final node = editorState.getNodeAtPath(selection.start.path);
  if (node == null) {
    return;
  }
  assert(node.delta != null);

  final transaction = editorState.transaction
    ..insertText(
      node,
      selection.startIndex,
      insertion.textInserted,
    );
  return editorState.apply(transaction);
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
