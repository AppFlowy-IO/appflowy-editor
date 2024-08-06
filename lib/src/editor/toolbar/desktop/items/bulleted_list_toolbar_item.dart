import 'package:appflowy_editor/appflowy_editor.dart';

final ToolbarItem bulletedListItem = ToolbarItem(
  id: 'editor.bulleted_list',
  group: 3,
  isActive: onlyShowInSingleSelectionAndTextType,
  builder: (context, editorState, highlightColor, iconColor, tooltipBuilder) {
    final selection = editorState.selection!;
    final node = editorState.getNodeAtPath(selection.start.path)!;
    final isHighlight = node.type == 'bulleted_list';
    final child = SVGIconItemWidget(
      iconName: 'toolbar/bulleted_list',
      isHighlight: isHighlight,
      highlightColor: highlightColor,
      iconColor: iconColor,
      onPressed: () => editorState.formatNode(
        selection,
        (node) => node.copyWith(
          type: isHighlight ? 'paragraph' : 'bulleted_list',
        ),
      ),
    );

    if (tooltipBuilder != null) {
      return tooltipBuilder(
        context,
        AppFlowyEditorL10n.current.bulletedList,
        child,
      );
    }

    return child;
  },
);
