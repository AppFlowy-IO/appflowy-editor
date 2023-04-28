import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/toolbar/items/icon_item_widget.dart';

ToolbarItem paragraphItem = ToolbarItem(
  id: 'editor.paragraph',
  isActive: (editorState) => editorState.selection?.isSingle ?? false,
  builder: (context, editorState) {
    final selection = editorState.selection!;
    final node = editorState.getNodeAtPath(selection.start.path)!;
    final isHighlight = node.type == 'numbered_list';
    return IconItemWidget(
      iconName: 'toolbar/numbered_list',
      isHighlight: isHighlight,
      tooltip: AppFlowyEditorLocalizations.current.numberedList,
      onPressed: () {},
    );
  },
);
