import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

ToolbarItem buildTextColorItem({
  List<ColorOption>? colorOptions,
}) {
  return ToolbarItem(
    id: 'editor.textColor',
    group: 4,
    isActive: onlyShowInTextType,
    builder: (context, editorState) {
      String? textColorHex;
      final selection = editorState.selection!;
      final nodes = editorState.getNodesInSelection(selection);
      final isHighlight = nodes.allSatisfyInSelection(selection, (delta) {
        return delta.everyAttributes(
          (attributes) => attributes[FlowyRichTextKeys.textColor] != null,
        );
      });
      return IconItemWidget(
        iconName: 'toolbar/text_color',
        isHighlight: isHighlight,
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
