import 'package:appflowy_editor/appflowy_editor.dart';

const _kTextColorItemId = 'editor.textColor';

ToolbarItem buildTextColorItem({
  List<ColorOption>? colorOptions,
}) {
  return ToolbarItem(
    id: _kTextColorItemId,
    group: 4,
    isActive: onlyShowInTextType,
    builder: (context, editorState, highlightColor, iconColor, tooltipBuilder) {
      String? textColorHex;
      final selection = editorState.selection!;
      final nodes = editorState.getNodesInSelection(selection);
      final isHighlight = nodes.allSatisfyInSelection(selection, (delta) {
        if (delta.everyAttributes((attr) => attr.isEmpty)) {
          return false;
        }

        return delta.everyAttributes((attr) {
          textColorHex = attr[AppFlowyRichTextKeys.textColor];
          return (textColorHex != null);
        });
      });

      final child = SVGIconItemWidget(
        iconName: 'toolbar/text_color',
        isHighlight: isHighlight,
        highlightColor: highlightColor,
        iconColor: iconColor,
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

      if (tooltipBuilder != null) {
        return tooltipBuilder(
          context,
          _kTextColorItemId,
          AppFlowyEditorL10n.current.textColor,
          child,
        );
      }

      return child;
    },
  );
}
