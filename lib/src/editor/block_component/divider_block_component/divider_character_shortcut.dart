import 'package:appflowy_editor/appflowy_editor.dart';

/// insert divider into a document by typing three minuses(-).
///
/// - support
///   - desktop
///   - web
///   - mobile
///
final CharacterShortcutEvent convertMinusesToDivider = CharacterShortcutEvent(
  key: 'convert minuses to a divider',
  character: '-',
  handler: (editorState) => _convertSyntaxToDivider(editorState, '--'),
);

final CharacterShortcutEvent convertStarsToDivider = CharacterShortcutEvent(
  key: 'convert starts to a divider',
  character: '*',
  handler: (editorState) => _convertSyntaxToDivider(editorState, '**'),
);

Future<bool> _convertSyntaxToDivider(
  EditorState editorState,
  String syntax,
) async {
  final selection = editorState.selection;
  if (selection == null || !selection.isCollapsed) {
    return false;
  }
  final path = selection.end.path;
  final node = editorState.getNodeAtPath(path);
  final delta = node?.delta;
  if (node == null || delta == null) {
    return false;
  }
  if (delta.toPlainText() != syntax) {
    return false;
  }
  final transaction = editorState.transaction
    ..insertNode(path, dividerNode())
    ..insertNode(path, paragraphNode())
    ..deleteNode(node)
    ..afterSelection = Selection.collapse(path, 0);
  editorState.apply(transaction);
  return true;
}
