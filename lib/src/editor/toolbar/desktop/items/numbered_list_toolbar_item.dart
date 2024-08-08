import 'package:appflowy_editor/appflowy_editor.dart';

const _kNumberedListItemId = 'editor.numbered_list';

final ToolbarItem numberedListItem = ToolbarItem(
  id: _kNumberedListItemId,
  group: 3,
  isActive: onlyShowInTextType,
  builder: (context, editorState, highlightColor, iconColor, tooltipBuilder) {
    final selection = editorState.selection!;
    final node = editorState.getNodeAtPath(selection.start.path)!;
    final isHighlight = node.type == 'numbered_list';
    final child = SVGIconItemWidget(
      iconName: 'toolbar/numbered_list',
      isHighlight: isHighlight,
      highlightColor: highlightColor,
      iconColor: iconColor,
      onPressed: () => editorState.formatNode(
        selection,
        (node) => node.copyWith(
          type: isHighlight ? 'paragraph' : 'numbered_list',
        ),
      ),
    );

    if (tooltipBuilder != null) {
      return tooltipBuilder(
        context,
        _kNumberedListItemId,
        AppFlowyEditorL10n.current.numberedList,
        child,
      );
    }

    return child;
  },
);
