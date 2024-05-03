import 'dart:io';

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/ime/character_shortcut_event_helper.dart';
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

  if (selection.isSingle) {
    final execution = await executeCharacterShortcutEvent(
      editorState,
      replacement.replacementText,
      characterShortcutEvents,
    );

    if (execution) {
      return;
    }

    if (Platform.isIOS) {
      // remove the trailing '\n' when pressing the return key
      if (replacement.replacementText.endsWith('\n')) {
        replacement = TextEditingDeltaReplacement(
          oldText: replacement.oldText,
          replacementText: replacement.replacementText
              .substring(0, replacement.replacementText.length - 1),
          replacedRange: replacement.replacedRange,
          selection: replacement.selection,
          composing: replacement.composing,
        );
      }
    }

    final node = editorState.getNodesInSelection(selection).first;
    final transaction = editorState.transaction;
    final start = replacement.replacedRange.start;
    final length = replacement.replacedRange.end - start;
    final afterSelection = Selection(
      start: Position(
        path: node.path,
        offset: replacement.selection.baseOffset,
      ),
      end: Position(
        path: node.path,
        offset: replacement.selection.extentOffset,
      ),
    );
    transaction
      ..replaceText(node, start, length, replacement.replacementText)
      ..afterSelection = afterSelection;
    await editorState.apply(transaction);
  } else {
    await editorState.deleteSelection(selection);
    // insert the replacement
    final insertion = replacement.toInsertion();
    await onInsert(
      insertion,
      editorState,
      characterShortcutEvents,
    );
  }
}

extension on TextEditingDeltaReplacement {
  TextEditingDeltaInsertion toInsertion() {
    final text = oldText.replaceRange(
      replacedRange.start,
      replacedRange.end,
      '',
    );
    return TextEditingDeltaInsertion(
      oldText: text,
      textInserted: replacementText,
      insertionOffset: replacedRange.start,
      selection: selection,
      composing: composing,
    );
  }
}
