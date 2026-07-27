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
          isActive: onlyShowInSingleSelectionAndTextType,
          builder: (
            context,
            editorState,
            highlightColor,
            iconColor,
            tooltipBuilder,
          ) {
            final selection = editorState.selection!;
            final node = editorState.getNodeAtPath(selection.start.path)!;
            final isHighlight =
                node.type == 'heading' && node.attributes['level'] == level;
            final child = SVGIconItemWidget(
              iconName: 'toolbar/h$level',
              isHighlight: isHighlight,
              highlightColor: highlightColor,
              iconColor: iconColor,
              onPressed: () {
                // Both the selection and each node's delta are read HERE, not
                // captured when this item was built. Hoisting them out was real
                // data loss: `formatNode` runs the callback for every node in
                // the selection, so one block's text was written over all of
                // them and the others' writing was destroyed (2026-07-27). The
                // build-time capture also went stale whenever the selection
                // grew while the toolbar stayed on screen.
                final selection = editorState.selection;
                if (selection == null) {
                  return;
                }
                editorState.formatNode(
                  selection,
                  (node) => node.copyWith(
                    type: isHighlight
                        ? ParagraphBlockKeys.type
                        : HeadingBlockKeys.type,
                    attributes: {
                      HeadingBlockKeys.level: level,
                      blockComponentBackgroundColor:
                          node.attributes[blockComponentBackgroundColor],
                      blockComponentTextDirection:
                          node.attributes[blockComponentTextDirection],
                      blockComponentDelta: (node.delta ?? Delta()).toJson(),
                    },
                  ),
                );
              },
            );

            if (tooltipBuilder != null) {
              return tooltipBuilder(
                context,
                'editor.h$level',
                levelToTooltips(level),
                child,
              );
            }

            return child;
          },
        );

  static String levelToTooltips(int level) {
    if (level == 1) {
      return AppFlowyEditorL10n.current.heading1;
    } else if (level == 2) {
      return AppFlowyEditorL10n.current.heading2;
    } else if (level == 3) {
      return AppFlowyEditorL10n.current.heading3;
    }

    return '';
  }
}
