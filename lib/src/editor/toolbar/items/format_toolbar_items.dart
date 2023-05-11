import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/toolbar/items/utils/tooltip_util.dart';
import 'package:appflowy_editor/src/editor/toolbar/items/icon_item_widget.dart';

final List<ToolbarItem> markdownFormatItems = [
  _FormatToolbarItem(
    id: 'editor.underline',
    name: 'underline',
    tooltip:
        '${AppFlowyEditorLocalizations.current.underline}${shortcutTooltips('⌘ + U', 'CTRL + U', 'CTRL + U')}',
  ),
  _FormatToolbarItem(
    id: 'editor.bold',
    name: 'bold',
    tooltip:
        '${AppFlowyEditorLocalizations.current.bold}${shortcutTooltips('⌘ + B', 'CTRL + B', 'CTRL + B')}',
  ),
  _FormatToolbarItem(
    id: 'editor.italic',
    name: 'italic',
    tooltip:
        '${AppFlowyEditorLocalizations.current.bold}${shortcutTooltips('⌘ + I', 'CTRL + I', 'CTRL + I')}',
  ),
  _FormatToolbarItem(
    id: 'editor.strikethrough',
    name: 'strikethrough',
    tooltip:
        '${AppFlowyEditorLocalizations.current.strikethrough}${shortcutTooltips('⌘ + SHIFT + S', 'CTRL + SHIFT + S', 'CTRL + SHIFT + S')}',
  ),
  _FormatToolbarItem(
    id: 'editor.code',
    name: 'code',
    tooltip:
        '${AppFlowyEditorLocalizations.current.strikethrough}${shortcutTooltips('⌘ + E', 'CTRL + E', 'CTRL + E')}',
  ),
];

class _FormatToolbarItem extends ToolbarItem {
  _FormatToolbarItem({
    required String id,
    required String name,
    required String tooltip,
  }) : super(
          id: 'editor.$id',
          isActive: (editorState) {
            final selection = editorState.selection;
            if (selection == null) {
              return false;
            }
            final nodes = editorState.getNodesInSelection(selection);
            return nodes.every((element) => element.delta != null);
          },
          builder: (context, editorState) {
            final selection = editorState.selection!;
            final nodes = editorState.getNodesInSelection(selection);
            final isHighlight = nodes.allSatisfyInSelection(selection, (delta) {
              return delta.everyAttributes(
                (attributes) => attributes[name] == true,
              );
            });
            return IconItemWidget(
              iconName: 'toolbar/$name',
              isHighlight: isHighlight,
              tooltip: tooltip,
              onPressed: () => editorState.toggleAttribute(name),
            );
          },
        );
}
