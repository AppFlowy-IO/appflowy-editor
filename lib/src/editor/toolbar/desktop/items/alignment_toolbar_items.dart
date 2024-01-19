import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/toolbar/desktop/items/utils/tooltip_util.dart';

final List<ToolbarItem> alignmentItems = [
  _AlignmentToolbarItem(
    id: 'align_left',
    name: 'left',
    align: 'left',
  ),
  _AlignmentToolbarItem(
    id: 'align_center',
    name: 'center',
    align: 'center',
  ),
  _AlignmentToolbarItem(
    id: 'align_right',
    name: 'right',
    align: 'right',
  ),
];

class _AlignmentToolbarItem extends ToolbarItem {
  _AlignmentToolbarItem({
    required String id,
    required String name,
    required String align,
  }) : super(
          id: 'editor.$id',
          group: 6,
          isActive: onlyShowInTextType,
          builder: (context, editorState, highlightColor, iconColor) {
            final selection = editorState.selection!;
            final nodes = editorState.getNodesInSelection(selection);
            final isHighlight = nodes.every(
              (n) => n.attributes[blockComponentAlign] == align,
            );

            return SVGIconItemWidget(
              iconName: 'toolbar/$name',
              isHighlight: isHighlight,
              highlightColor: highlightColor,
              iconColor: iconColor,
              tooltip: getTooltipText(id),
              onPressed: () => editorState.updateNode(
                selection,
                (node) => node.copyWith(
                  attributes: {
                    ...node.attributes,
                    blockComponentAlign: align,
                  },
                ),
              ),
            );
          },
        );
}
