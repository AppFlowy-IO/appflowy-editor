import 'package:appflowy_editor/appflowy_editor.dart';

final List<ToolbarItem> alignmentItems = [
  _AlignmentToolbarItem(
    id: 'align_left',
    name: 'left',
    tooltip: 'left',
    align: 'left',
  ),
  _AlignmentToolbarItem(
    id: 'align_center',
    name: 'center',
    tooltip: 'center',
    align: 'center',
  ),
  _AlignmentToolbarItem(
    id: 'align_right',
    name: 'right',
    tooltip: 'right',
    align: 'right',
  ),
];

class _AlignmentToolbarItem extends ToolbarItem {
  _AlignmentToolbarItem({
    required String id,
    required String name,
    required String tooltip,
    required String align,
  }) : super(
          id: 'editor.$id',
          group: 6,
          isActive: onlyShowInTextType,
          builder: (context, editorState, highlightColor) {
            final selection = editorState.selection!;
            final nodes = editorState.getNodesInSelection(selection);
            final isHighlight = nodes.every(
              (n) => n.attributes[blockComponentAlign] == align,
            );

            return SVGIconItemWidget(
              iconName: 'toolbar/$name',
              isHighlight: isHighlight,
              highlightColor: highlightColor,
              tooltip: tooltip,
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
