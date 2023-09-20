import 'package:appflowy_editor/appflowy_editor.dart';

ToolbarItem buildTextColorItem({
  List<ColorOption>? colorOptions,
}) {
  return ToolbarItem(
    id: 'editor.textColor',
    group: 4,
    isActive: onlyShowInTextType,
    builder: (context, editorState, highlightColor) {
      String? textColorHex;
      final selection = editorState.selection!;
      final nodes = editorState.getNodesInSelection(selection);
      final isHighlight = nodes.allSatisfyInSelection(selection, (delta) {
        return delta.everyAttributes((attributes) {
          textColorHex = attributes[AppFlowyRichTextKeys.textColor];
          return (textColorHex != null);
        });
      });
      return SVGIconItemWidget(
        iconName: 'toolbar/text_color',
        isHighlight: isHighlight,
        highlightColor: highlightColor,
        tooltip: AppFlowyEditorLocalizations.current.textColor,
        onPressed: () {
          bool showClearButton = false;
          nodes.allSatisfyInSelection(
            selection,
            (delta) {
              if (!showClearButton) {
                showClearButton = delta.whereType<TextInsert>().any(
                  (element) {
                    return element
                            .attributes?[AppFlowyRichTextKeys.textColor] !=
                        null;
                  },
                );
              }
              return true;
            },
          );
          showColorMenu(
            context,
            editorState,
            selection,
            currentColorHex: textColorHex,
            isTextColor: true,
            textColorOptions: colorOptions,
            showClearButton: showClearButton,
          );
        },
      );
    },
  );
}
