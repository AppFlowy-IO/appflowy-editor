import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/toolbar/items/delta_util.dart';
import 'package:appflowy_editor/src/editor/toolbar/items/tooltip_util.dart';
import 'package:appflowy_editor/src/editor/toolbar/items/icon_item_widget.dart';

final linkItem = ToolbarItem(
  id: 'editor.link',
  isActive: (editorState) => editorState.selection?.isSingle ?? false,
  builder: (context, editorState) {
    final selection = editorState.selection!;
    final nodes = editorState.getNodesInSelection(selection);
    final isHighlight = nodes.allSatisfyInSelection(selection, (delta) {
      return delta.everyAttributes(
        (attributes) => attributes['href'] != null,
      );
    });
    return IconItemWidget(
      iconName: 'toolbar/link',
      isHighlight: isHighlight,
      tooltip:
          '${AppFlowyEditorLocalizations.current.link}${shortcutTooltips("⌘ + K", "CTRL + K", "CTRL + K")}',
      onPressed: () {},
    );
  },
);
