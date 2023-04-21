import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/services.dart';
import '../../../../util/util.dart';

/// insert a new line block
///
/// - on desktop or web: enter
/// - on mobile: enter
///
CharacterShortcutEvent insertNewLine = CharacterShortcutEvent(
  key: 'insert a new line',
  character: '\n',
  handler: _insertNewLineHandler,
);

CharacterShortcutEventHandler _insertNewLineHandler = (editorState) async {
  // on desktop or web, shift + enter to insert a '\n' character to the same line.
  // so, we should return the false to let the system handle it.
  if (PlatformExtension.isNotMobile && RawKeyboard.instance.isShiftPressed) {
    return false;
  }

  final selection = editorState.selection?.normalized;
  if (selection == null) {
    return false;
  }

  // delete the selection
  await editorState.deleteSelection(selection);
  // insert a new line
  await editorState.insertNewLine(selection.start);

  return true;
};
