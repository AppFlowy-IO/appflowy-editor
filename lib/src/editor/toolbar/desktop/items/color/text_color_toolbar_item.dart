import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

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
      return IconItemWidget(
        iconName: 'toolbar/text_color',
        isHighlight: isHighlight,
        highlightColor: highlightColor,
        iconSize: const Size.square(14),
        tooltip: AppFlowyEditorLocalizations.current.textColor,
        onPressed: () {
          showColorMenu(
            context,
            editorState,
            selection,
            currentColorHex: textColorHex,
            isTextColor: true,
            textColorOptions: colorOptions,
          );
        },
      );
    },
  );
}
