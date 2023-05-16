import 'package:appflowy_editor/appflowy_editor.dart';

List<ToolbarItem> headingItems = [1, 2, 3]
    .map((index) => _HeadingToolbarItem(index))
    .toList(growable: false);

class _HeadingToolbarItem extends ToolbarItem {
  final int level;

  _HeadingToolbarItem(this.level)
      : super(
          id: 'editor.h$level',
          group: 1,
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
                  type: isHighlight
                      ? ParagraphBlockKeys.type
                      : HeadingBlockKeys.type,
                  attributes: {
                    HeadingBlockKeys.level: level,
                    HeadingBlockKeys.backgroundColor:
                        node.attributes[blockComponentBackgroundColor],
                    'delta': (node.delta ?? Delta()).toJson(),
                  },
                ),
              ),
            );
          },
        );
}
