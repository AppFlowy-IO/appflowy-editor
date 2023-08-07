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
  handler: (editorState) async =>
      await _convertSyntaxToDivider(editorState, '--') ||
      await _convertSyntaxToDivider(editorState, '—'),
);

final CharacterShortcutEvent convertStarsToDivider = CharacterShortcutEvent(
  key: 'convert stars to a divider',
  character: '*',
  handler: (editorState) => _convertSyntaxToDivider(editorState, '**'),
);

final CharacterShortcutEvent convertUnderscoreToDivider =
    CharacterShortcutEvent(
  key: 'convert underscore to a divider',
  character: '_',
  handler: (editorState) => _convertSyntaxToDivider(editorState, '__'),
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
    ..afterSelection = Selection.collapsed(Position(path: path));
  editorState.apply(transaction);
  return true;
}
