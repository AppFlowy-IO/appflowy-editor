import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/toolbar/items/icon_item_widget.dart';

ToolbarItem heading1Item = ToolbarItem(
  id: 'editor.h1',
  isActive: (editorState) => editorState.selection?.isSingle ?? false,
  builder: (context, editorState) {
    final selection = editorState.selection!;
    final node = editorState.getNodeAtPath(selection.start.path)!;
    final isHighlight = node.type == 'heading' && node.attributes['level'] == 1;
    return IconItemWidget(
      iconName: 'toolbar/h1',
      isHighlight: isHighlight,
      tooltip: AppFlowyEditorLocalizations.current.heading1,
      onPressed: () {},
    );
  },
);

ToolbarItem heading2Item = ToolbarItem(
  id: 'editor.h2',
  isActive: (editorState) => editorState.selection?.isSingle ?? false,
  builder: (context, editorState) {
    final selection = editorState.selection!;
    final node = editorState.getNodeAtPath(selection.start.path)!;
    final isHighlight = node.type == 'heading' && node.attributes['level'] == 2;
    return IconItemWidget(
      iconName: 'toolbar/h2',
      isHighlight: isHighlight,
      tooltip: AppFlowyEditorLocalizations.current.heading2,
      onPressed: () {},
    );
  },
);

ToolbarItem heading3Item = ToolbarItem(
  id: 'editor.h3',
  isActive: (editorState) => editorState.selection?.isSingle ?? false,
  builder: (context, editorState) {
    final selection = editorState.selection!;
    final node = editorState.getNodeAtPath(selection.start.path)!;
    final isHighlight = node.type == 'heading' && node.attributes['level'] == 3;
    return IconItemWidget(
      iconName: 'toolbar/h3',
      isHighlight: isHighlight,
      tooltip: AppFlowyEditorLocalizations.current.heading3,
      onPressed: () {},
    );
  },
);
