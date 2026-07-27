import 'package:appflowy_editor/appflowy_editor.dart';

const _kParagraphItemId = 'editor.paragraph';

final ToolbarItem paragraphItem = ToolbarItem(
  id: _kParagraphItemId,
  group: 1,
  isActive: onlyShowInSingleSelectionAndTextType,
  builder: (context, editorState, highlightColor, iconColor, tooltipBuilder) {
    final selection = editorState.selection!;
    final node = editorState.getNodeAtPath(selection.start.path)!;
    final isHighlight = node.type == 'paragraph';
    final child = SVGIconItemWidget(
      iconName: 'toolbar/text',
      isHighlight: isHighlight,
      highlightColor: highlightColor,
      iconColor: iconColor,
      // Read the selection and each node's delta at press time. See the note in
      // heading_toolbar_items.dart -- hoisting the delta out of this callback
      // wrote one block's text over every block in the selection.
      onPressed: () {
        final selection = editorState.selection;
        if (selection == null) {
          return;
        }
        editorState.formatNode(
          selection,
          (node) => node.copyWith(
            type: ParagraphBlockKeys.type,
            attributes: {
              blockComponentDelta: (node.delta ?? Delta()).toJson(),
              blockComponentBackgroundColor:
                  node.attributes[blockComponentBackgroundColor],
              blockComponentTextDirection:
                  node.attributes[blockComponentTextDirection],
            },
          ),
        );
      },
    );

    if (tooltipBuilder != null) {
      return tooltipBuilder(
        context,
        _kParagraphItemId,
        AppFlowyEditorL10n.current.text,
        child,
      );
    }

    return child;
  },
);
