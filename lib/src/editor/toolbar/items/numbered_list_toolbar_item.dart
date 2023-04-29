import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/toolbar/items/icon_item_widget.dart';

ToolbarItem numberedListItem = ToolbarItem(
  id: 'editor.numbered_list',
  isActive: (editorState) => editorState.selection?.isSingle ?? false,
  builder: (context, editorState) {
    final selection = editorState.selection!;
    final node = editorState.getNodeAtPath(selection.start.path)!;
    final isHighlight = node.type == 'numbered_list';
    return IconItemWidget(
      iconName: 'toolbar/numbered_list',
      isHighlight: isHighlight,
      tooltip: AppFlowyEditorLocalizations.current.numberedList,
      onPressed: () => editorState.formatNode(
        selection,
        (node) => node.copyWith(
          type: isHighlight ? 'paragraph' : 'numbered_list',
          attributes: {
            'delta': (node.delta ?? Delta()).toJson(),
          },
        ),
      ),
    );
  },
);
