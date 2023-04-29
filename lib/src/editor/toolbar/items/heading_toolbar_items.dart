import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/toolbar/items/icon_item_widget.dart';

List<ToolbarItem> headingItems = [1, 2, 3]
    .map((index) => _HeadingToolbarItem(index))
    .toList(growable: false);

class _HeadingToolbarItem extends ToolbarItem {
  final int level;

  _HeadingToolbarItem(this.level)
      : super(
          id: 'editor.h$level',
          isActive: (editorState) => editorState.selection?.isSingle ?? false,
          builder: (context, editorState) {
            final selection = editorState.selection!;
            final node = editorState.getNodeAtPath(selection.start.path)!;
            final isHighlight =
                node.type == 'heading' && node.attributes['level'] == level;
            return IconItemWidget(
              iconName: 'toolbar/h$level',
              isHighlight: isHighlight,
              tooltip: AppFlowyEditorLocalizations.current.heading1,
              onPressed: () => editorState.formatNode(
                selection,
                (node) => node.copyWith(
                  type: isHighlight ? 'paragraph' : 'heading',
                  attributes: {
                    'level': level,
                    'delta': (node.delta ?? Delta()).toJson(),
                  },
                ),
              ),
            );
          },
        );
}
