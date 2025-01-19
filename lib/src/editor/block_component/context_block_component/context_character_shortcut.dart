import 'package:appflowy_editor/appflowy_editor.dart';

CharacterShortcutEvent formatDoubleQuestionToContext = CharacterShortcutEvent(
  key: 'format double question to context',
  character: '?',
  handler: (editorState) async => await formatMarkdownSymbol(
    editorState,
    (node) => node.type != ContextBlockKeys.type,
    (_, text, __) => text.endsWith('??'),
    (_, node, delta) => [
      contextNode(
        attributes: {
          ContextBlockKeys.delta: delta.compose(Delta()..delete(2)).toJson(),
        },
      ),
      if (node.children.isNotEmpty) ...node.children,
    ],
  ),
);
