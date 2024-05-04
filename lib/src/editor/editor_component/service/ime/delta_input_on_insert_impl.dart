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

  final textInserted = insertion.textInserted;

  // character shortcut events
  final execution = await executeCharacterShortcutEvent(
    editorState,
    textInserted,
    characterShortcutEvents,
  );

  if (execution) {
    return;
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

  final afterSelection = Selection(
    start: Position(
      path: node.path,
      offset: insertion.selection.baseOffset,
    ),
    end: Position(
      path: node.path,
      offset: insertion.selection.extentOffset,
    ),
  );

  final transaction = editorState.transaction
    ..insertText(
      node,
      selection.startIndex,
      textInserted,
      toggledAttributes: editorState.toggledStyle,
    )
    ..afterSelection = afterSelection;
  return editorState.apply(transaction);
}
