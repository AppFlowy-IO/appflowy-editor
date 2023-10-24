import 'package:appflowy_editor/appflowy_editor.dart';

final ToolbarItem paragraphItem = ToolbarItem(
  id: 'editor.paragraph',
  group: 1,
  isActive: onlyShowInSingleSelectionAndTextType,
  builder: (context, editorState, highlightColor, iconColor) {
    final selection = editorState.selection!;
    final node = editorState.getNodeAtPath(selection.start.path)!;
    final isHighlight = node.type == 'paragraph';
    final delta = (node.delta ?? Delta()).toJson();
    return SVGIconItemWidget(
      iconName: 'toolbar/text',
      isHighlight: isHighlight,
      highlightColor: highlightColor,
      iconColor: iconColor,
      tooltip: AppFlowyEditorL10n.current.text,
      onPressed: () => editorState.formatNode(
        selection,
        (node) => node.copyWith(
          type: ParagraphBlockKeys.type,
          attributes: {
            blockComponentDelta: delta,
            blockComponentBackgroundColor:
                node.attributes[blockComponentBackgroundColor],
            blockComponentTextDirection:
                node.attributes[blockComponentTextDirection],
          },
        ),
      ),
    );
  },
);
