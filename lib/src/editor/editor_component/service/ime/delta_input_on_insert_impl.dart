import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/ime/character_shortcut_event_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

Future<void> onInsert(
  TextEditingDeltaInsertion insertion,
  EditorState editorState,
  List<CharacterShortcutEvent> characterShortcutEvents,
) async {
  Log.input.debug('onInsert: $insertion');

  final oldText = insertion.oldText;
  final textInserted = insertion.textInserted;

  // record the location of the '\' character
  // 1 means [textInserted] is '\'
  // 2 means the last character of [oldText] is '\'
  // 0 means no '\' character, execute the shortcut event
  var backSlashLocation = 0;
// exclude the wrapped style shortcut events
// like _abc_, **abc**,__abc__ ~~abc~~, `abc`
  if (oldText.isNotEmpty &&
      oldText[oldText.length - 1] == '\\' &&
      (textInserted == '_' ||
          textInserted == '*' ||
          textInserted == '~' ||
          textInserted == '`')) {
    backSlashLocation = 1;
// exclude space enabled shortcut events
// like - abc, " abc, > abc, # abc, -[] abc
  } else if (oldText.length >= 2 &&
      oldText[oldText.length - 2] == '\\' &&
      (oldText[oldText.length - 1] == '-' ||
          oldText[oldText.length - 1] == '"' ||
          oldText[oldText.length - 1] == '>' ||
          oldText[oldText.length - 1] == '#' ||
          oldText[oldText.length - 1] == ']') &&
      textInserted == ' ') {
    backSlashLocation = 2;
  } else {
    // character shortcut events
    final execution = await executeCharacterShortcutEvent(
      editorState,
      textInserted,
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

  if (kDebugMode) {
    // verify the toggled keys are supported.
    assert(
      editorState.toggledStyle.keys.every(
        (element) => AppFlowyRichTextKeys.supportToggled.contains(element),
      ),
    );
  }

  // delete the '\' character if the shortcut event is ignored.
  if (backSlashLocation > 0) {
    final transaction = editorState.transaction
      ..deleteText(
        node,
        selection.startIndex - backSlashLocation,
        1,
      )
      ..insertText(
        node,
        selection.startIndex - 1,
        textInserted,
        toggledAttributes: editorState.toggledStyle,
      );

    return editorState.apply(transaction);
  }

  final transaction = editorState.transaction
    ..insertText(
      node,
      selection.startIndex,
      textInserted,
      toggledAttributes: editorState.toggledStyle,
    );
  return editorState.apply(transaction);
}
