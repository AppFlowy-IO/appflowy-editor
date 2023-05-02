import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/ime/delta_input_impl.dart';
import 'package:flutter/services.dart';

Future<void> onReplace(
  TextEditingDeltaReplacement replacement,
  EditorState editorState,
  List<CharacterShortcutEvent> characterShortcutEvents,
) async {
  Log.input.debug('onReplace: $replacement');

  // delete the selection
  final selection = editorState.selection;
  if (selection == null) {
    return;
  }
  await editorState.deleteSelection(selection);

  // insert the replacement
  final insertion = replacement.toInsertion();
  await onInsert(
    insertion,
    editorState,
    characterShortcutEvents,
  );
}

extension on TextEditingDeltaReplacement {
  TextEditingDeltaInsertion toInsertion() {
    final text = oldText.replaceRange(
      selection.start,
      selection.end,
      '',
    );
    return TextEditingDeltaInsertion(
      oldText: text,
      textInserted: replacementText,
      insertionOffset: selection.start,
      selection: selection,
      composing: composing,
    );
  }
}
