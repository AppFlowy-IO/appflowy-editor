import 'package:appflowy_editor/appflowy_editor.dart';

final ToolbarItem bulletedListItem = ToolbarItem(
  id: 'editor.bulleted_list',
  group: 3,
  isActive: onlyShowInSingleSelectionAndTextType,
  builder: (context, editorState, highlightColor, iconColor) {
    final selection = editorState.selection!;
    final node = editorState.getNodeAtPath(selection.start.path)!;
    final isHighlight = node.type == 'bulleted_list';
    return SVGIconItemWidget(
      iconName: 'toolbar/bulleted_list',
      isHighlight: isHighlight,
      highlightColor: highlightColor,
      iconColor: iconColor,
      tooltip: AppFlowyEditorL10n.current.bulletedList,
      onPressed: () => editorState.formatNode(
        selection,
        (node) => node.copyWith(
          type: isHighlight ? 'paragraph' : 'bulleted_list',
        ),
      ),
    );
  },
);
