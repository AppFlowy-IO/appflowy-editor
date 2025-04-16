import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/editor_component/service/ime/character_shortcut_event_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:universal_platform/universal_platform.dart';

Future<void> onInsert(
  TextEditingDeltaInsertion insertion,
  EditorState editorState,
  List<CharacterShortcutEvent> characterShortcutEvents,
) async {
  AppFlowyEditorLog.input.debug('onInsert: $insertion');

  final textInserted = insertion.textInserted;

  /// On mobile devices, the "/" is context-sensitive,which means it can't be
  /// recognized as a standalone character. This requires special handling.
  final isMobileSlash =
      UniversalPlatform.isMobile && insertion.textInserted == '/';

  // In France, the backtick key is used to toggle a character style.
  // We should prevent the execution of character shortcut events when the
  // composing range is not collapsed.
  if (insertion.composing.isCollapsed || isMobileSlash) {
    // execute character shortcut events
    final execution = await executeCharacterShortcutEvent(
      editorState,
      textInserted,
      characterShortcutEvents,
    );

    if (execution) {
      editorState.sliceUpcomingAttributes = false;
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
      sliceAttributes: editorState.sliceUpcomingAttributes,
    )
    ..afterSelection = afterSelection;
  await editorState.apply(transaction);
}
