import 'package:appflowy_editor/appflowy_editor.dart';

final ToolbarItem numberedListItem = ToolbarItem(
  id: 'editor.numbered_list',
  group: 3,
  isActive: onlyShowInSingleSelectionAndTextType,
  builder: (context, editorState, highlightColor, iconColor) {
    final selection = editorState.selection!;
    final node = editorState.getNodeAtPath(selection.start.path)!;
    final isHighlight = node.type == 'numbered_list';
    return SVGIconItemWidget(
      iconName: 'toolbar/numbered_list',
      isHighlight: isHighlight,
      highlightColor: highlightColor,
      iconColor: iconColor,
      tooltip: AppFlowyEditorL10n.current.numberedList,
      onPressed: () => editorState.formatNode(
        selection,
        (node) => node.copyWith(
          type: isHighlight ? 'paragraph' : 'numbered_list',
        ),
      ),
    );
  },
);
