import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/toolbar/desktop/items/utils/tooltip_util.dart';

final List<ToolbarItem> markdownFormatItems = [
  _FormatToolbarItem(
    id: 'underline',
    name: 'underline',
    tooltip:
        '${AppFlowyEditorL10n.current.underline}${shortcutTooltips('⌘ + U', 'CTRL + U', 'CTRL + U')}',
  ),
  _FormatToolbarItem(
    id: 'bold',
    name: 'bold',
    tooltip:
        '${AppFlowyEditorL10n.current.bold}${shortcutTooltips('⌘ + B', 'CTRL + B', 'CTRL + B')}',
  ),
  _FormatToolbarItem(
    id: 'italic',
    name: 'italic',
    tooltip:
        '${AppFlowyEditorL10n.current.italic}${shortcutTooltips('⌘ + I', 'CTRL + I', 'CTRL + I')}',
  ),
  _FormatToolbarItem(
    id: 'strikethrough',
    name: 'strikethrough',
    tooltip:
        '${AppFlowyEditorL10n.current.strikethrough}${shortcutTooltips('⌘ + SHIFT + S', 'CTRL + SHIFT + S', 'CTRL + SHIFT + S')}',
  ),
  _FormatToolbarItem(
    id: 'code',
    name: 'code',
    tooltip:
        '${AppFlowyEditorL10n.current.embedCode}${shortcutTooltips('⌘ + E', 'CTRL + E', 'CTRL + E')}',
  ),
];

class _FormatToolbarItem extends ToolbarItem {
  _FormatToolbarItem({
    required String id,
    required String name,
    required String tooltip,
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
              tooltip: tooltip,
              onPressed: () => editorState.toggleAttribute(name),
            );
          },
        );
}
