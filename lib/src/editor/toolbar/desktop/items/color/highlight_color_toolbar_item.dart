import 'package:appflowy_editor/appflowy_editor.dart';

const _kHighlightColorItemId = 'editor.highlightColor';

ToolbarItem buildHighlightColorItem({List<ColorOption>? colorOptions}) {
  return ToolbarItem(
    id: _kHighlightColorItemId,
    group: 4,
    isActive: onlyShowInTextType,
    builder: (context, editorState, highlightColor, iconColor, tooltipBuilder) {
      String? highlightColorHex;

      final selection = editorState.selection!;
      final nodes = editorState.getNodesInSelection(selection);
      final isHighlight = nodes.allSatisfyInSelection(selection, (delta) {
        if (delta.everyAttributes((attr) => attr.isEmpty)) {
          return false;
        }

        return delta.everyAttributes((attributes) {
          highlightColorHex = attributes[AppFlowyRichTextKeys.backgroundColor];
          return highlightColorHex != null;
        });
      });

      final child = SVGIconItemWidget(
        iconName: 'toolbar/highlight_color',
        isHighlight: isHighlight,
        highlightColor: highlightColor,
        iconColor: iconColor,
        onPressed: () {
          bool showClearButton = false;
          nodes.allSatisfyInSelection(selection, (delta) {
            if (!showClearButton) {
              showClearButton = delta.whereType<TextInsert>().any(
                (element) {
                  return element
                          .attributes?[AppFlowyRichTextKeys.backgroundColor] !=
                      null;
                },
              );
            }
            return true;
          });
          showColorMenu(
            context,
            editorState,
            selection,
            currentColorHex: highlightColorHex,
            isTextColor: false,
            highlightColorOptions: colorOptions,
            showClearButton: showClearButton,
          );
        },
      );

      if (tooltipBuilder != null) {
        return tooltipBuilder(
          context,
          _kHighlightColorItemId,
          AppFlowyEditorL10n.current.highlightColor,
          child,
        );
      }

      return child;
    },
  );
}
