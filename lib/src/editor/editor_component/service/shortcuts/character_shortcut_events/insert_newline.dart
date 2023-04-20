import 'package:appflowy_editor/src/editor/editor_component/service/extensions/extensions.dart';
import 'package:appflowy_editor/src/editor/block_component/block_component.dart';

CharacterShortcutEventHandler _insertNewLineHandler = (editorState) async {
  final selection = editorState.selection.currentSelection.value;

  // delete the selection
  await editorState.deleteSelection(selection);

  // insert a new line
  await editorState.insertNewLine2(selection);

  return true;
};

CharacterShortcutEvent insertNewLine = CharacterShortcutEvent(
  key: 'insert a new line',
  character: '\n',
  handler: _insertNewLineHandler,
);
