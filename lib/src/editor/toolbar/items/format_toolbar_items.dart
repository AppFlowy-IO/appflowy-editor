import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/util/delta_util.dart';
import 'package:appflowy_editor/src/editor/toolbar/items/tooltip_util.dart';
import 'package:appflowy_editor/src/editor/toolbar/items/icon_item_widget.dart';

List<ToolbarItem> formatItems = _formatItems
    .map(
      (e) => ToolbarItem(
        id: 'editor.${e.name}',
        isActive: (editorState) => editorState.selection?.isSingle ?? false,
        builder: (context, editorState) {
          final selection = editorState.selection!;
          final nodes = editorState.getNodesInSelection(selection);
          final isHighlight = nodes.allSatisfyInSelection(selection, (delta) {
            return delta.everyAttributes(
              (attributes) => attributes[e.name] == true,
            );
          });
          return IconItemWidget(
            iconName: 'toolbar/${e.name}',
            isHighlight: isHighlight,
            tooltip: e.tooltip,
            onPressed: () {},
          );
        },
      ),
    )
    .toList();

class _FormatItem {
  const _FormatItem({
    required this.name,
    required this.tooltip,
  });

  final String name;
  final String tooltip;
}

List<_FormatItem> _formatItems = [
  _FormatItem(
    name: 'underline',
    tooltip:
        '${AppFlowyEditorLocalizations.current.underline}${shortcutTooltips('⌘ + U', 'CTRL + U', 'CTRL + U')}',
  ),
  _FormatItem(
    name: 'bold',
    tooltip:
        '${AppFlowyEditorLocalizations.current.bold}${shortcutTooltips('⌘ + B', 'CTRL + B', 'CTRL + B')}',
  ),
  _FormatItem(
    name: 'italic',
    tooltip:
        '${AppFlowyEditorLocalizations.current.bold}${shortcutTooltips('⌘ + I', 'CTRL + I', 'CTRL + I')}',
  ),
  _FormatItem(
    name: 'strikethrough',
    tooltip:
        '${AppFlowyEditorLocalizations.current.strikethrough}${shortcutTooltips('⌘ + SHIFT + S', 'CTRL + SHIFT + S', 'CTRL + SHIFT + S')}',
  ),
  _FormatItem(
    name: 'code',
    tooltip:
        '${AppFlowyEditorLocalizations.current.strikethrough}${shortcutTooltips('⌘ + E', 'CTRL + E', 'CTRL + E')}',
  ),
];
