import 'package:appflowy_editor/appflowy_editor.dart';

ToolbarItem buildHighlightColorItem({List<ColorOption>? colorOptions}) {
  return ToolbarItem(
    id: 'editor.highlightColor',
    group: 4,
    isActive: onlyShowInTextType,
    builder: (context, editorState, highlightColor, iconColor) {
      String? highlightColorHex;

      final selection = editorState.selection!;
      final nodes = editorState.getNodesInSelection(selection);
      final isHighlight = nodes.allSatisfyInSelection(selection, (delta) {
        return delta.everyAttributes((attributes) {
          highlightColorHex = attributes[AppFlowyRichTextKeys.backgroundColor];
          return highlightColorHex != null;
        });
      });
      return SVGIconItemWidget(
        iconName: 'toolbar/highlight_color',
        isHighlight: isHighlight,
        highlightColor: highlightColor,
        iconColor: iconColor,
        tooltip: AppFlowyEditorL10n.current.highlightColor,
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
    },
  );
}
