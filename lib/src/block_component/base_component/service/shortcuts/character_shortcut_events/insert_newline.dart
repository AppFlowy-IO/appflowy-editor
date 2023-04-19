import 'package:appflowy_editor/src/block_component/base_component/service/extensions/extensions.dart';
import 'package:appflowy_editor/src/block_component/block_component.dart';

CharacterShortcutEventHandler _insertNewLineHandler = (editorState) async {
  final selection = editorState.selection.currentSelection.value;

  // delete the selection
  await editorState.deleteSelection(selection);

  // insert a new line
  editorState.insertNewLine2(selection);

  return true;
};

CharacterShortcutEvent newlineShortcutEvent = CharacterShortcutEvent(
  key: 'insert a new line',
  character: '\n',
  handler: _insertNewLineHandler,
);
