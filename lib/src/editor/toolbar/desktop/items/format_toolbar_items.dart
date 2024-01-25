import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/toolbar/desktop/items/utils/tooltip_util.dart';

final List<ToolbarItem> markdownFormatItems = [
  _FormatToolbarItem(
    id: 'underline',
    name: 'underline',
  ),
  _FormatToolbarItem(
    id: 'bold',
    name: 'bold',
  ),
  _FormatToolbarItem(
    id: 'italic',
    name: 'italic',
  ),
  _FormatToolbarItem(
    id: 'strikethrough',
    name: 'strikethrough',
  ),
  _FormatToolbarItem(
    id: 'code',
    name: 'code',
  ),
];

class _FormatToolbarItem extends ToolbarItem {
  _FormatToolbarItem({
    required String id,
    required String name,
  }) : super(
          id: 'editor.$id',
          group: 2,
          isActive: onlyShowInTextType,
          builder: (context, editorState, highlightColor, iconColor) {
            final selection = editorState.selection!;
            final nodes = editorState.getNodesInSelection(selection);
            final isHighlight = nodes.allSatisfyInSelection(selection, (delta) {
              return delta.everyAttributes(
                (attributes) => attributes[name] == true,
              );
            });
            return SVGIconItemWidget(
              iconName: 'toolbar/$name',
              isHighlight: isHighlight,
              highlightColor: highlightColor,
              iconColor: iconColor,
              tooltip: getTooltipText(id),
              onPressed: () => editorState.toggleAttribute(name),
            );
          },
        );
}
