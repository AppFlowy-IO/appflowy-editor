import 'package:appflowy_editor/appflowy_editor.dart';

final ToolbarItem paragraphItem = ToolbarItem(
  id: 'editor.paragraph',
  isActive: (editorState) => editorState.selection?.isSingle ?? false,
  builder: (context, editorState) {
    final selection = editorState.selection!;
    final node = editorState.getNodeAtPath(selection.start.path)!;
    final isHighlight = node.type == 'paragraph';
    return IconItemWidget(
      iconName: 'toolbar/text',
      isHighlight: isHighlight,
      tooltip: AppFlowyEditorLocalizations.current.text,
      onPressed: () => editorState.formatNode(
        selection,
        (node) => node.copyWith(
          type: ParagraphBlockKeys.type,
          attributes: {
            'delta': (node.delta ?? Delta()).toJson(),
            ParagraphBlockKeys.backgroundColor:
                node.attributes[blockComponentBackgroundColor],
          },
        ),
      ),
    );
  },
);
