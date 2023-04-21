import 'package:appflowy_editor/src/editor/block_component/block_component.dart';

CharacterShortcutEventHandler _markdownBlockHandler = (editorState) async {
  final selection = editorState.selection;
  return false;
};

/// #  -> heading
/// *  -> bulleted-list
/// [] -> todo-slit
/// 1. -> numbered-list
///
CharacterShortcutEvent markdownBlockSyntax = CharacterShortcutEvent(
  key: 'convert markdown block syntax to block component',
  character: ' ',
  handler: _markdownBlockHandler,
);
