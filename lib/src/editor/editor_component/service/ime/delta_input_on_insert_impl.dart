import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';

Future<bool> executeCharacterShortcutEvent(
  EditorState editorState,
  String character,
) async {
  final shortcutEvents = editorState.characterShortcutEvents;
  for (final shortcutEvent in shortcutEvents) {
    if (shortcutEvent.character == character &&
        await shortcutEvent.handler(editorState)) {
      return true;
    }
  }
  return false;
}

Future<void> onInsert(
  TextEditingDeltaInsertion insertion,
  EditorState editorState,
) async {
  Log.input.debug('onInsert: $insertion');

  // character events
  final character = insertion.textInserted;
  if (character.length == 1) {
    final execution = await executeCharacterShortcutEvent(
      editorState,
      character,
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
