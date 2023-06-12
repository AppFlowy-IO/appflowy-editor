import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/toolbar/desktop/items/utils/tooltip_util.dart';

// unused now.
final highlightItem = ToolbarItem(
  id: 'editor.highlight',
  group: 5,
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
