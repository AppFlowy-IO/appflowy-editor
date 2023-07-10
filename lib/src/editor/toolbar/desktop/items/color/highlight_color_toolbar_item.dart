import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

ToolbarItem buildHighlightColorItem({List<ColorOption>? colorOptions}) {
  return ToolbarItem(
    id: 'editor.highlightColor',
    group: 4,
    isActive: onlyShowInTextType,
    builder: (context, editorState, highlightColor) {
      String? highlightColorHex;

      final selection = editorState.selection!;
      final nodes = editorState.getNodesInSelection(selection);
      final isHighlight = nodes.allSatisfyInSelection(selection, (delta) {
        return delta.everyAttributes((attributes) {
          highlightColorHex = attributes[AppFlowyRichTextKeys.highlightColor];
          return highlightColorHex != null;
        });
      });
      return IconItemWidget(
        iconName: 'toolbar/highlight_color',
        iconSize: const Size.square(14),
        isHighlight: isHighlight,
        highlightColor: highlightColor,
        tooltip: AppFlowyEditorLocalizations.current.highlightColor,
        onPressed: () {
          showColorMenu(
            context,
            editorState,
            selection,
            currentColorHex: highlightColorHex,
            isTextColor: false,
            highlightColorOptions: colorOptions,
          );
        },
      );
    },
  );
}
