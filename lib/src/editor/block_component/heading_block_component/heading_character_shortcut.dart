import 'package:appflowy_editor/appflowy_editor.dart';

/// Convert '# ' to bulleted list
///
/// - support
///   - desktop
///   - mobile
///   - web
///
CharacterShortcutEvent formatSignToHeading = CharacterShortcutEvent(
  key: 'format sign to heading list',
  character: ' ',
  handler: (editorState) async => await formatMarkdownSymbol(
    editorState,
    (node) => true,
    (_, text, selection) {
      final characters = text.split('');
      // only supports heading1 to heading6 levels
      // if the characters is empty, the every function will return true directly
      return characters.isNotEmpty &&
          characters.every((element) => element == '#') &&
          characters.length < 7;
    },
    (text, node, delta) {
      final numberOfSign = text.split('').length;
      return [
        headingNode(
          level: numberOfSign,
          delta: delta.compose(Delta()..delete(numberOfSign)),
        ),
        if (node.children.isNotEmpty) ...node.children,
      ];
    },
  ),
);

/// Insert a new block after the heading block.
///
/// - support
///   - desktop
///   - web
///   - mobile
///
CharacterShortcutEvent insertNewLineAfterHeading = CharacterShortcutEvent(
  key: 'insert new block after heading',
  character: '\n',
  handler: (editorState) async {
    final selection = editorState.selection;
    if (selection == null ||
        !selection.isCollapsed ||
        selection.startIndex != 0) {
      return false;
    }
    final node = editorState.getNodeAtPath(selection.end.path);
    if (node == null || node.type != HeadingBlockKeys.type) {
      return false;
    }
    final transaction = editorState.transaction;
    transaction.insertNode(selection.start.path, paragraphNode());
    transaction.afterSelection = Selection.collapsed(
      Position(path: selection.start.path.next, offset: 0),
    );
    await editorState.apply(transaction);
    return true;
  },
);
