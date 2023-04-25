import 'package:appflowy_editor/appflowy_editor.dart';

const _underscore = '_';

/// format the text surrounded by two underscores to italic
///
/// - support
///   - desktop
///   - mobile
///   - web
///
CharacterShortcutEvent formatUnderscoreToItalic = CharacterShortcutEvent(
  key: 'format the text surrounded by two underscores to italic',
  character: _underscore,
  handler: _formatItalic,
);

CharacterShortcutEventHandler _formatItalic = (editorState) async {
  final selection = editorState.selection;
  // if the selection is not collapsed,
  //  we should return false to let the IME handle it.
  if (selection == null || !selection.isCollapsed) {
    return false;
  }

  final path = selection.end.path;
  final node = editorState.getNodeAtPath(path);
  final delta = node?.delta;
  // if the node doesn't contain the delta, we should return directly.
  if (node == null || delta == null) {
    return false;
  }

  final plainText = delta.toPlainText();
  final underScore1 = plainText.indexOf(_underscore);
  final underScore2 = plainText.lastIndexOf(_underscore);

  // Determine if an 'underscore' already exists in the node and only once.
  // 1. can't find the first underscore.
  // 2. there're more than one underscore before.
  // 3. there're two underscores connecting together, like __.
  if (underScore1 == -1 ||
      underScore1 != underScore2 ||
      underScore1 == selection.end.offset - 1) {
    return false;
  }

  // if all the conditions are met, we should format the text to italic.
  // 1. delete the previous 'underscore',
  // 2. update the style of the text surrounded by the two underscores to 'italic',
  //  and update the cursor position.

  final deletion = editorState.transaction
    ..deleteText(
      node,
      underScore1,
      _underscore.length,
    );
  editorState.apply(deletion);
  final format = editorState.transaction
    ..formatText(
      node,
      underScore1,
      selection.end.offset - underScore1 - 1,
      {
        'italic': true,
      },
    )
    ..afterSelection = Selection.collapsed(
      Position(
        path: path,
        offset: selection.end.offset - 1,
      ),
    );
  editorState.apply(format);
  return true;
};
